import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.email, this.token});

  final String id;
  final String email;
  final String? token;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[id, email, token];
}
