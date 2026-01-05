import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  PreferencesStorage(this._preferences);

  final SharedPreferences _preferences;

  Future<bool> writeString(String key, String value) => _preferences.setString(key, value);

  String? readString(String key) => _preferences.getString(key);

  Future<bool> writeBool(String key, bool value) => _preferences.setBool(key, value);

  bool? readBool(String key) => _preferences.getBool(key);

  Future<bool> remove(String key) => _preferences.remove(key);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());
final preferencesStorageProvider = Provider<PreferencesStorage>((ref) => PreferencesStorage(ref.read(sharedPreferencesProvider)));
