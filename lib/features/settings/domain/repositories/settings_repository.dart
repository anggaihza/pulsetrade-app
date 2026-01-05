import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> load();

  Future<Either<Failure, AppSettings>> updateTheme(AppThemeMode mode);

  Future<Either<Failure, AppSettings>> updateLocale(LocaleCode? locale);
}
