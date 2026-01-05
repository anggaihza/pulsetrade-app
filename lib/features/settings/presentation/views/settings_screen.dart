import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_card.dart';
import 'package:pulsetrade_app/features/settings/domain/entities/app_settings.dart';
import 'package:pulsetrade_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final settingsValue = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: settingsValue.when(
          data: (settings) => ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.theme,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: AppThemeMode.values
                          .map(
                            (mode) => ChoiceChip(
                              label: Text(_labelForTheme(mode, strings)),
                              selected: settings.themeMode == mode,
                              onSelected: (_) => controller.changeTheme(mode),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.language,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String?>(
                      isExpanded: true,
                      value: settings.locale,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(strings.system),
                        ),
                        const DropdownMenuItem<String?>(
                          value: 'en',
                          child: Text('English'),
                        ),
                        const DropdownMenuItem<String?>(
                          value: 'es',
                          child: Text('Español'),
                        ),
                      ],
                      onChanged: (value) {
                        controller.changeLocale(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  String _labelForTheme(AppThemeMode mode, AppLocalizations strings) {
    switch (mode) {
      case AppThemeMode.light:
        return strings.light;
      case AppThemeMode.dark:
        return strings.dark;
      case AppThemeMode.system:
        return strings.system;
    }
  }
}
