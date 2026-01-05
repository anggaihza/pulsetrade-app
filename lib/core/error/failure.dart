import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => <Object?>[message, cause];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.cause});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
