import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';

class SecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);
}

final secureStorageProvider = Provider<SecureStorage>(
  (ref) => const SecureStorage(FlutterSecureStorage()),
);
