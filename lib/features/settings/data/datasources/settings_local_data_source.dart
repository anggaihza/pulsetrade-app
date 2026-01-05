import 'package:pulsetrade_app/core/storage/preferences/preferences_storage.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._storage);

  final PreferencesStorage _storage;

  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale_code';

  Future<void> saveTheme(String value) => _storage.writeString(themeKey, value);

  String? readTheme() => _storage.readString(themeKey);

  Future<void> saveLocale(String? value) async {
    if (value == null) {
      await _storage.remove(localeKey);
    } else {
      await _storage.writeString(localeKey, value);
    }
  }

  String? readLocale() => _storage.readString(localeKey);
}
