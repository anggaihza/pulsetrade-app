import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({required String email, required String password});

  Future<Either<Failure, User>> register({required String email, required String password});

  Future<Either<Failure, Unit>> logout();

  Future<Option<User>> currentUser();
}
