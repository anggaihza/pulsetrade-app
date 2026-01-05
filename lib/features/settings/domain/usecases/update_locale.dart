import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/features/settings/domain/entities/app_settings.dart';
import 'package:pulsetrade_app/features/settings/domain/repositories/settings_repository.dart';

class UpdateLocale extends UseCase<AppSettings, UpdateLocaleParams> {
  UpdateLocale(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Either<Failure, AppSettings>> call(UpdateLocaleParams params) {
    return _repository.updateLocale(params.locale);
  }
}

class UpdateLocaleParams {
  const UpdateLocaleParams(this.locale);

  final LocaleCode? locale;
}
