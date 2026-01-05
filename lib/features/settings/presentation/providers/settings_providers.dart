import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/storage/preferences/preferences_storage.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:pulsetrade_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:pulsetrade_app/features/settings/domain/entities/app_settings.dart';
import 'package:pulsetrade_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:pulsetrade_app/features/settings/domain/usecases/get_settings.dart';
import 'package:pulsetrade_app/features/settings/domain/usecases/update_locale.dart';
import 'package:pulsetrade_app/features/settings/domain/usecases/update_theme.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSource(ref.watch(preferencesStorageProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider)),
);

final getSettingsUseCaseProvider = Provider<GetSettings>((ref) => GetSettings(ref.watch(settingsRepositoryProvider)));
final updateThemeUseCaseProvider = Provider<UpdateTheme>((ref) => UpdateTheme(ref.watch(settingsRepositoryProvider)));
final updateLocaleUseCaseProvider = Provider<UpdateLocale>((ref) => UpdateLocale(ref.watch(settingsRepositoryProvider)));

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  FutureOr<AppSettings> build() async {
    final result = await ref.read(getSettingsUseCaseProvider)(const NoParams());
    return result.getOrElse((_) => const AppSettings());
  }

  Future<void> changeTheme(AppThemeMode mode) async {
    state = const AsyncLoading();
    final result = await ref.read(updateThemeUseCaseProvider)(UpdateThemeParams(mode));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (settings) => AsyncData(settings),
    );
  }

  Future<void> changeLocale(LocaleCode? locale) async {
    state = const AsyncLoading();
    final result = await ref.read(updateLocaleUseCaseProvider)(UpdateLocaleParams(locale));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (settings) => AsyncData(settings),
    );
  }
}
