import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/features/settings/domain/entities/app_settings.dart';
import 'package:pulsetrade_app/features/settings/domain/repositories/settings_repository.dart';

class UpdateTheme extends UseCase<AppSettings, UpdateThemeParams> {
  UpdateTheme(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Either<Failure, AppSettings>> call(UpdateThemeParams params) {
    return _repository.updateTheme(params.mode);
  }
}

class UpdateThemeParams {
  const UpdateThemeParams(this.mode);

  final AppThemeMode mode;
}
