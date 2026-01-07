import 'package:pulsetrade_app/core/storage/cache/cache_client.dart';
import 'package:pulsetrade_app/core/storage/secure/secure_storage.dart';
import 'package:pulsetrade_app/features/auth/data/models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._secureStorage, this._cacheClient);

  final SecureStorage _secureStorage;
  final CacheClient _cacheClient;

  static const String _tokenKey = 'auth_token';
  static const String _localContactKey = 'local_auth_contact';
  static const String _localPasswordKey = 'local_auth_password';
  static const String _box = 'userBox';
  static const String _userKey = 'currentUser';

  Future<void> cacheUser(UserModel user) async {
    if (user.token != null) {
      await _secureStorage.write(_tokenKey, user.token!);
    }
    await _cacheClient.write<Map<String, dynamic>>(_box, _userKey, user.toJson());
  }

  Future<UserModel?> readUser() async {
    final stored = _cacheClient.read<Map<String, dynamic>>(_box, _userKey);
    final token = await _secureStorage.read(_tokenKey);
    if (stored is! Map<String, dynamic>) return null;
    final merged = Map<String, dynamic>.from(stored);
    if (token != null) {
      merged['token'] = token;
    }
    return UserModel.fromJson(merged);
  }

  Future<void> cacheCredentials({
    required String contact,
    required String password,
  }) async {
    final normalized = contact.trim();
    await _secureStorage.write(_localContactKey, normalized);
    await _secureStorage.write(_localPasswordKey, password);
  }

  Future<bool> validateCredentials({
    required String contact,
    required String password,
  }) async {
    final normalized = contact.trim();
    final storedContact = await _secureStorage.read(_localContactKey);
    final storedPassword = await _secureStorage.read(_localPasswordKey);
    if (storedContact == null || storedPassword == null) return false;
    return storedContact == normalized && storedPassword == password;
  }

  Future<void> cacheLocalUser({
    required String id,
    required String contact,
    required String token,
  }) async {
    final normalized = contact.trim();
    await cacheUser(UserModel(id: id, email: normalized, token: token));
  }

  Future<void> clear() async {
    await _secureStorage.delete(_tokenKey);
    await _cacheClient.delete(_box, _userKey);
  }
}
