import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_card.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/login_screen.dart';
import 'package:pulsetrade_app/features/home/presentation/views/home_feed_screen.dart';
import 'package:pulsetrade_app/features/settings/presentation/views/settings_screen.dart';
import 'package:pulsetrade_app/features/survey/presentation/views/survey_form_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String routePath = '/';
  static const String routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider).asData?.value;
    final email = authState?.user?.email ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/${SettingsScreen.routeName}'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              strings.welcomeMessage(email),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const _NavigationCard(
              title: '📱 Trading Feed',
              description:
                  'TikTok-style video feed with stock charts and interactions.',
              route: HomeFeedScreen.routePath,
            ),
            const SizedBox(height: 16),
            const _NavigationCard(
              title: 'Survey',
              description:
                  'Complex form with async validation and conditional fields.',
              route: '/${SurveyFormScreen.routeName}',
            ),
            const _NavigationCard(
              title: 'Settings',
              description: 'Theme toggle and localization preferences.',
              route: '/${SettingsScreen.routeName}',
            ),
            _NavigationCard(
              title: strings.logout,
              description: 'Sign out from the application.',
              route: LoginScreen.routePath,
              onTap: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go(LoginScreen.routePath);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.title,
    required this.description,
    required this.route,
    this.onTap,
  });

  final String title;
  final String description;
  final String route;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () => context.go(route),
      ),
    );
  }
}
