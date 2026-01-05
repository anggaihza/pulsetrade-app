import 'package:dio/dio.dart';
import 'package:pulsetrade_app/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );
    final data = response.data ?? <String, dynamic>{};
    return UserModel.fromJson((data['user'] as Map<String, dynamic>?) ?? data);
  }

  Future<UserModel> register({required String email, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{'email': email, 'password': password},
    );
    final data = response.data ?? <String, dynamic>{};
    return UserModel.fromJson((data['user'] as Map<String, dynamic>?) ?? data);
  }

  Future<void> logout(String token) async {
    await _dio.post<void>(
      '/auth/logout',
      options: Options(headers: <String, String>{'Authorization': 'Bearer $token'}),
    );
  }
}
