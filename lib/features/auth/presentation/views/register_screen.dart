import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_text_field.dart';
import 'package:pulsetrade_app/core/presentation/widgets/google_button.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/login_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/otp_verification_screen.dart';
import 'package:pulsetrade_app/core/utils/toast_utils.dart';
import 'package:pulsetrade_app/core/utils/validators.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/verification_type.dart';
import 'package:pulsetrade_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:pulsetrade_app/features/home/presentation/views/home_feed_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Register screen matching the Figma design
///
/// This screen displays a dark-themed registration form with:
/// - Email/Phone number input field
/// - Terms of Service checkbox
/// - Continue button
/// - Google Sign-In option
/// - Link to existing account login
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const String routePath = '/register';
  static const String routeName = 'register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _hasContactError = false;
  bool _acceptedTerms = false;
  ProviderSubscription<AsyncValue<AuthState>>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = ref.listenManual<AsyncValue<AuthState>>(
      authControllerProvider,
      (previous, next) {
        if (!mounted) return;
        if (next.hasError) {
          final failure = next.error;
          showErrorToast(context, failure.toString());
        }
        if (next.hasValue && next.value?.isAuthenticated == true) {
          context.go(HomeScreen.routePath);
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authSubscription?.close();
    super.dispose();
  }

  /// Automatically detects if the input is an email or phone number
  VerificationType _detectContactType(String contact) {
    // Check if it contains @ symbol - likely an email
    if (contact.contains('@')) {
      return VerificationType.email;
    }

    // Otherwise treat it as a phone number
    return VerificationType.phone;
  }

  void _handleRegister() async {
    final strings = AppLocalizations.of(context);
    final contact = _emailController.text.trim();

    // Reset error state on each attempt
    setState(() => _hasContactError = false);

    if (contact.isEmpty) {
      setState(() => _hasContactError = true);
      showErrorToast(context, strings.pleaseEnterEmail);
      return;
    }

    // Automatically detect if input is email or phone
    final verificationType = _detectContactType(contact);

    // Validate based on detected type
    if (verificationType == VerificationType.email) {
      if (!Validators.isValidEmail(contact)) {
        setState(() => _hasContactError = true);
        showErrorToast(context, strings.invalidEmailFormat);
        return;
      }
    } else {
      if (!Validators.isValidPhone(contact)) {
        setState(() => _hasContactError = true);
        showErrorToast(context, strings.invalidPhoneFormat);
        return;
      }
    }

    if (!_acceptedTerms) {
      showErrorToast(context, strings.pleaseAcceptTerms);
      return;
    }

    // TODO: Trigger OTP request API call here.
    ref.read(authControllerProvider.notifier).startRegistration(
      contact: contact,
      verificationType: verificationType,
    );

    // Navigate to OTP verification screen with detected type
    // Use push so that back button returns to this Register screen
    if (mounted) {
      context.push(
        Uri(
          path: OTPVerificationScreen.routePath,
          queryParameters: {
            'contact': contact,
            'type': verificationType == VerificationType.email
                ? 'email'
                : 'phone',
          },
        ).toString(),
      );
    }
  }

  void _handleContactChanged(String value) {
    final contact = value.trim();

    // Clear error when user is editing
    setState(() => _hasContactError = false);

    if (contact.isEmpty) {
      return;
    }

    final verificationType = _detectContactType(contact);

    if (verificationType == VerificationType.email) {
      if (!Validators.isValidEmail(contact)) {
        setState(() => _hasContactError = true);
      }
    } else {
      if (!Validators.isValidPhone(contact)) {
        setState(() => _hasContactError = true);
      }
    }
  }

  void _handleGoogleSignIn() {
    final strings = AppLocalizations.of(context);
    // TODO: Implement Google sign-in functionality
    showWarningToast(context, strings.googleSignInNotImplemented);
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: "Welcome!"
                    Text(strings.welcome, style: AppTextStyles.displaySmall()),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      strings.registerSubtitle,
                      style: AppTextStyles.bodyLarge(
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                // Form section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email/Phone number field
                        AppTextField(
                          label: strings.emailPhoneLabel,
                          placeholder: strings.emailPhonePlaceholder,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hasError: _hasContactError,
                          onChanged: _handleContactChanged,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Terms of Service checkbox
                        _buildTermsCheckbox(strings),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Continue button
                        AppButton(
                          label: strings.continueButton,
                          onPressed: _handleRegister,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Or divider
                        const OrDivider(),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Google sign-in button
                        GoogleButton(
                          label: strings.continueWithGoogle,
                          onPressed: _handleGoogleSignIn,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Already have account link
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => context.go(LoginScreen.routePath),
                            child: Text(
                              strings.iHavePulseAccount,
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

  Widget _buildTermsCheckbox(AppLocalizations strings) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Checkbox
        GestureDetector(
          onTap: () {
            setState(() {
              _acceptedTerms = !_acceptedTerms;
            });
          },
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textTertiary, width: 1),
              borderRadius: BorderRadius.circular(4),
              color: _acceptedTerms ? AppColors.primary : Colors.transparent,
            ),
            child: _acceptedTerms
                ? const Icon(Icons.check, size: 12, color: AppColors.onPrimary)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        // Terms text
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium().copyWith(
                height: 1.5, // Better line height for multi-line text
              ),
              children: [
                TextSpan(text: strings.termsAgreement),
                TextSpan(text: ' '),
                TextSpan(
                  text: strings.termsOfService,
                  style: AppTextStyles.bodyMedium().copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Navigate to Terms of Service
                      showWarningToast(context, 'Terms of Service screen');
                    },
                ),
                TextSpan(text: ' ${strings.and} '),
                TextSpan(
                  text: strings.privacyPolicy,
                  style: AppTextStyles.bodyMedium().copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Navigate to Privacy Policy
                      showWarningToast(context, 'Privacy Policy screen');
                    },
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
