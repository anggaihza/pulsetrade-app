import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/localization/localization.dart';
import 'package:pulsetrade_app/core/router/app_router.dart';
import 'package:pulsetrade_app/core/theme/app_theme.dart';
import 'package:pulsetrade_app/features/settings/domain/entities/app_settings.dart';
import 'package:pulsetrade_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    return MaterialApp.router(
      title: 'PulseTrade',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mapTheme(settings?.themeMode),
      locale: settings?.locale != null ? Locale(settings!.locale!) : null,
      supportedLocales: supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  ThemeMode _mapTheme(AppThemeMode? mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      case null:
        return ThemeMode.system;
    }
  }
}
