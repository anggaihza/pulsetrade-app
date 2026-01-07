import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/network/dio_client.dart';
import 'package:pulsetrade_app/core/network/network_info.dart';
import 'package:pulsetrade_app/core/storage/cache/cache_client.dart';
import 'package:pulsetrade_app/core/storage/secure/secure_storage.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pulsetrade_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pulsetrade_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/verification_type.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/user.dart';
import 'package:pulsetrade_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pulsetrade_app/features/auth/domain/usecases/login.dart';
import 'package:pulsetrade_app/features/auth/domain/usecases/logout.dart';
import 'package:pulsetrade_app/features/auth/domain/usecases/register.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(ref.watch(secureStorageProvider), ref.watch(cacheClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final loginUseCaseProvider = Provider<Login>((ref) => Login(ref.watch(authRepositoryProvider)));
final registerUseCaseProvider = Provider<Register>((ref) => Register(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider<Logout>((ref) => Logout(ref.watch(authRepositoryProvider)));

class RegistrationDraft {
  const RegistrationDraft({
    required this.contact,
    required this.verificationType,
    this.otpVerified = false,
    this.password,
  });

  final String contact;
  final VerificationType verificationType;
  final bool otpVerified;
  final String? password;

  bool get hasPassword => password != null && password!.isNotEmpty;
  bool get isReadyToRegister => otpVerified && hasPassword;

  RegistrationDraft copyWith({
    String? contact,
    VerificationType? verificationType,
    bool? otpVerified,
    String? password,
  }) {
    return RegistrationDraft(
      contact: contact ?? this.contact,
      verificationType: verificationType ?? this.verificationType,
      otpVerified: otpVerified ?? this.otpVerified,
      password: password ?? this.password,
    );
  }
}

class AuthState {
  const AuthState({this.user, this.registration});

  final User? user;
  final RegistrationDraft? registration;

  bool get isAuthenticated => user?.isAuthenticated ?? false;

  AuthState copyWith({User? user, RegistrationDraft? registration, bool clearRegistration = false}) {
    return AuthState(
      user: user ?? this.user,
      registration: clearRegistration ? null : registration ?? this.registration,
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  // TODO: Move to environment config once API auth is ready.
  static const bool _preferLocalAuth = true;

  @override
  FutureOr<AuthState> build() async {
    final userOption = await ref.read(authRepositoryProvider).currentUser();
    return userOption.match(() => const AuthState(), (user) => AuthState(user: user));
  }

  void startRegistration({
    required String contact,
    required VerificationType verificationType,
  }) {
    final current = state.value ?? const AuthState();
    state = AsyncData(
      current.copyWith(
        registration: RegistrationDraft(
          contact: contact,
          verificationType: verificationType,
        ),
      ),
    );
  }

  Future<bool> verifyOtp(String code) async {
    final current = state.value ?? const AuthState();
    final registration = current.registration;
    if (registration == null) return false;
    state = const AsyncLoading();
    // TODO: Replace local validation with OTP verification API call.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final isValid = code == '123456';
    state = AsyncData(
      current.copyWith(
        registration: registration.copyWith(
          otpVerified: registration.otpVerified || isValid,
        ),
      ),
    );
    return isValid;
  }

  Future<bool> savePassword(String password) async {
    final current = state.value ?? const AuthState();
    final registration = current.registration;
    if (registration == null || !registration.otpVerified) return false;
    state = const AsyncLoading();
    // TODO: Replace local update with password setup API call.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = AsyncData(
      current.copyWith(
        registration: registration.copyWith(password: password),
      ),
    );
    return true;
  }

  Future<bool> completeRegistration() async {
    final current = state.value ?? const AuthState();
    final registration = current.registration;
    if (registration == null || !registration.isReadyToRegister) return false;
    state = const AsyncLoading();
    final localDataSource = ref.read(authLocalDataSourceProvider);
    final contact = registration.contact.trim();
    // TODO: Replace local user creation with register API call.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await localDataSource.cacheCredentials(
      contact: contact,
      password: registration.password!,
    );
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: contact,
      token: 'local_token',
    );
    await localDataSource.cacheLocalUser(
      id: user.id,
      contact: user.email,
      token: user.token ?? 'local_token',
    );
    state = AsyncData(AuthState(user: user));
    return true;
  }

  Future<void> login(String email, String password) async {
    if (_preferLocalAuth) {
      state = const AsyncLoading();
      final localDataSource = ref.read(authLocalDataSourceProvider);
      final normalized = email.trim();
      final isValid = await localDataSource.validateCredentials(
        contact: normalized,
        password: password,
      );
      if (!isValid) {
        state = AsyncError(
          const AuthFailure('Invalid credentials'),
          StackTrace.current,
        );
        return;
      }
      final cachedUser = await localDataSource.readUser();
      final user =
          cachedUser != null && cachedUser.email == normalized
              ? cachedUser
              : User(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  email: normalized,
                  token: 'local_token',
                );
      await localDataSource.cacheLocalUser(
        id: user.id,
        contact: user.email,
        token: user.token ?? 'local_token',
      );
      state = AsyncData(AuthState(user: user));
      return;
    }
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider)(LoginParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(AuthState(user: user)),
    );
  }

  Future<void> register(String email, String password) async {
    if (_preferLocalAuth) {
      state = const AsyncLoading();
      final localDataSource = ref.read(authLocalDataSourceProvider);
      final normalized = email.trim();
      await localDataSource.cacheCredentials(
        contact: normalized,
        password: password,
      );
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: normalized,
        token: 'local_token',
      );
      await localDataSource.cacheLocalUser(
        id: user.id,
        contact: user.email,
        token: user.token ?? 'local_token',
      );
      state = AsyncData(AuthState(user: user));
      return;
    }
    state = const AsyncLoading();
    final result = await ref.read(registerUseCaseProvider)(RegisterParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(AuthState(user: user)),
    );
  }

  Future<void> logout() async {
    if (_preferLocalAuth) {
      final localDataSource = ref.read(authLocalDataSourceProvider);
      await localDataSource.clear();
      state = const AsyncData(AuthState());
      return;
    }
    final result = await ref.read(logoutUseCaseProvider)(const NoParams());
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(AuthState()),
    );
  }
}
