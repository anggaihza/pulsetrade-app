import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/user.dart';
import 'package:pulsetrade_app/features/auth/domain/repositories/auth_repository.dart';

class Register extends UseCase<User, RegisterParams> {
  Register(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(email: params.email, password: params.password);
  }
}

class RegisterParams {
  const RegisterParams({required this.email, required this.password});

  final String email;
  final String password;
}
