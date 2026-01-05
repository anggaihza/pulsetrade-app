import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:pulsetrade_app/features/settings/domain/entities/app_settings.dart';
import 'package:pulsetrade_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AppSettings>> load() async {
    try {
      final theme = _localDataSource.readTheme();
      final locale = _localDataSource.readLocale();
      final appTheme = _mapTheme(theme);
      return right(AppSettings(themeMode: appTheme, locale: locale));
    } catch (exception) {
      return left(UnknownFailure('Unable to load settings', cause: exception));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> updateLocale(LocaleCode? locale) async {
    try {
      await _localDataSource.saveLocale(locale);
      final settings = await load();
      return settings;
    } catch (exception) {
      return left(UnknownFailure('Unable to update locale', cause: exception));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> updateTheme(AppThemeMode mode) async {
    try {
      await _localDataSource.saveTheme(mode.name);
      final settings = await load();
      return settings;
    } catch (exception) {
      return left(UnknownFailure('Unable to update theme', cause: exception));
    }
  }

  AppThemeMode _mapTheme(String? raw) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => AppThemeMode.system,
    );
  }
}
