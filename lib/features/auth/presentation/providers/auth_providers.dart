import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/network/dio_client.dart';
import 'package:pulsetrade_app/core/network/network_info.dart';
import 'package:pulsetrade_app/core/storage/cache/cache_client.dart';
import 'package:pulsetrade_app/core/storage/secure/secure_storage.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pulsetrade_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pulsetrade_app/features/auth/data/repositories/auth_repository_impl.dart';
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

class AuthState {
  const AuthState({this.user});

  final User? user;

  bool get isAuthenticated => user?.isAuthenticated ?? false;
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  FutureOr<AuthState> build() async {
    final userOption = await ref.read(authRepositoryProvider).currentUser();
    return userOption.match(() => const AuthState(), (user) => AuthState(user: user));
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider)(LoginParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(AuthState(user: user)),
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(registerUseCaseProvider)(RegisterParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(AuthState(user: user)),
    );
  }

  Future<void> logout() async {
    final result = await ref.read(logoutUseCaseProvider)(const NoParams());
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(AuthState()),
    );
  }
}
