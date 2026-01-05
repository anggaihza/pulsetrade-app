import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/user.dart';
import 'package:pulsetrade_app/features/auth/domain/repositories/auth_repository.dart';

class Login extends UseCase<User, LoginParams> {
  Login(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}
