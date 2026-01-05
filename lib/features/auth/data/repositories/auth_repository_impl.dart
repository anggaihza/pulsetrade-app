import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/network/dio_client.dart';
import 'package:pulsetrade_app/core/network/network_info.dart';
import 'package:pulsetrade_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pulsetrade_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/user.dart';
import 'package:pulsetrade_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }
    try {
      final user = await _remoteDataSource.login(email: email, password: password);
      await _localDataSource.cacheUser(user);
      return right(user);
    } on DioException catch (exception) {
      return left(mapDioException(exception));
    } catch (exception) {
      return left(UnknownFailure('Login failed', cause: exception));
    }
  }

  @override
  Future<Either<Failure, User>> register({required String email, required String password}) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('No internet connection'));
    }
    try {
      final user = await _remoteDataSource.register(email: email, password: password);
      await _localDataSource.cacheUser(user);
      return right(user);
    } on DioException catch (exception) {
      return left(mapDioException(exception));
    } catch (exception) {
      return left(UnknownFailure('Registration failed', cause: exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final cachedUser = await _localDataSource.readUser();
    final token = cachedUser?.token;
    try {
      if (token != null && token.isNotEmpty) {
        await _remoteDataSource.logout(token);
      }
      await _localDataSource.clear();
      return right(unit);
    } on DioException catch (exception) {
      return left(mapDioException(exception));
    } catch (exception) {
      return left(UnknownFailure('Logout failed', cause: exception));
    }
  }

  @override
  Future<Option<User>> currentUser() async {
    final user = await _localDataSource.readUser();
    return Option.fromNullable(user);
  }
}
