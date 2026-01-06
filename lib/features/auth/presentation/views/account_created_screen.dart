import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/presentation/views/home_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Account Created Success Screen
///
/// This screen confirms successful account creation and welcomes the user.
/// Features:
/// - Success message with title and subtitle
/// - 3D checkmark illustration
/// - Continue button to proceed to home
class AccountCreatedScreen extends ConsumerWidget {
  const AccountCreatedScreen({super.key});

  static const String routePath = '/account-created';
  static const String routeName = 'account_created';

  void _handleContinue(BuildContext context) {
    context.go(HomeScreen.routePath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success message
                Column(
                  children: [
                    // Title: "Account created!"
                    Text(
                      strings.accountCreated,
                      style: AppTextStyles.labelLarge().copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      strings.accountCreatedSubtitle,
                      style: AppTextStyles.bodyLarge(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // 3D Checkmark illustration
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.asset(
                    'assets/images/success_checkmark.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: strings.continueButton,
                    onPressed: () => _handleContinue(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

