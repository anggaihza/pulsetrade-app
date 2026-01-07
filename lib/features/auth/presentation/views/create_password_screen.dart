import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_text_field.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/toast_utils.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/create_pin_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Create Password Screen
///
/// This screen allows users to create a password after email/phone verification.
/// Features:
/// - Password input with show/hide toggle
/// - Real-time password validation
/// - Visual feedback for password requirements
class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  static const String routePath = '/create-password';
  static const String routeName = 'create-password';

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUpperLower = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      // 6-12 characters
      _hasMinLength = password.length >= 6 && password.length <= 12;

      // Capital and lowercase letters
      _hasUpperLower =
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]'));

      // A number
      _hasNumber = password.contains(RegExp(r'[0-9]'));

      // A special character
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength && _hasUpperLower && _hasNumber && _hasSpecialChar;

  Future<void> _handleContinue() async {
    final strings = AppLocalizations.of(context);

    if (!_isPasswordValid) {
      showErrorToast(context, strings.pleaseCompletePasswordRequirements);
      return;
    }

    final saved = await ref
        .read(authControllerProvider.notifier)
        .savePassword(_passwordController.text);
    if (!mounted) return;
    if (!saved) {
      showErrorToast(context, strings.invalidOtpCode);
      return;
    }
    // Navigate to Create PIN screen after successful password creation.
    // Use push so that back button returns to this screen.
    context.push(CreatePinScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

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
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      TablerIcons.lock_square_rounded_filled,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      strings.createPassword,
                      style: AppTextStyles.labelLarge().copyWith(fontSize: 24),
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
                        // Password field
                        AppTextField(
                          label: strings.passwordLabel,
                          placeholder: strings.passwordPlaceholder,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Password requirements
                        _PasswordRequirement(
                          text: strings.passwordRequirement6to12,
                          isMet: _hasMinLength,
                        ),
                        const SizedBox(height: 4),
                        _PasswordRequirement(
                          text: strings.passwordRequirementUpperLower,
                          isMet: _hasUpperLower,
                        ),
                        const SizedBox(height: 4),
                        _PasswordRequirement(
                          text: strings.passwordRequirementNumber,
                          isMet: _hasNumber,
                        ),
                        const SizedBox(height: 4),
                        _PasswordRequirement(
                          text: strings.passwordRequirementSpecialChar,
                          isMet: _hasSpecialChar,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Continue button
                        AppButton(
                          label: strings.continueButton,
                          onPressed: _handleContinue,
                          isLoading: isLoading,
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

/// Password requirement item with check indicator
class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({required this.text, required this.isMet});

  final String text;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? TablerIcons.circle_dashed_check : TablerIcons.circle_dashed,
          size: 16,
          color: isMet ? const Color(0xFF1BC865) : AppColors.textLabel,
        ),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodyMedium(color: AppColors.textLabel)),
      ],
    );
  }
}
