import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark, system }

typedef LocaleCode = String;

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.locale,
  });

  final AppThemeMode themeMode;
  final LocaleCode? locale;

  AppSettings copyWith({AppThemeMode? themeMode, LocaleCode? locale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => <Object?>[themeMode, locale];
}
