import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/otp_input.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/account_created_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Create PIN Screen
///
/// This screen allows users to set a 6-digit PIN for app access.
/// Features:
/// - 6-digit PIN input
/// - Skip option
/// - Navigation to home after setup
class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  static const String routePath = '/create-pin';
  static const String routeName = 'create-pin';

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  String _pinCode = '';
  bool _isLoading = false;

  void _handlePinChange(String pin) {
    setState(() {
      _pinCode = pin;
    });
  }

  void _handlePinComplete(String pin) {
    setState(() {
      _pinCode = pin;
    });
  }

  void _handleContinue() {
    final strings = AppLocalizations.of(context);

    if (_pinCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pleaseEnter6DigitPin)),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement PIN save API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(AccountCreatedScreen.routePath);
      }
    });
  }

  void _handleSkip() {
    // Skip PIN setup and go to account created screen
    context.go(AccountCreatedScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        TablerIcons.password,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        strings.setPIN,
                        style: AppTextStyles.labelLarge().copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.setPINSubtitle,
                    style: AppTextStyles.bodyLarge(
                      color: AppColors.textSecondary,
                    ).copyWith(height: 1.4),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PIN input (reusing OTP input component)
                      OTPInput(
                        length: 6,
                        onChanged: _handlePinChange,
                        onCompleted: _handlePinComplete,
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
                      // Continue button
                      AppButton(
                        label: strings.continueButton,
                        onPressed: _handleContinue,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
                      // Skip for now link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _handleSkip,
                          child: Text(
                            strings.skipForNow,
                            style: AppTextStyles.link(),
                          ),
                        ),
                      ),
                    ],
                  ),
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

