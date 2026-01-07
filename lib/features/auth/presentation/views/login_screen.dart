import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_text_field.dart';
import 'package:pulsetrade_app/core/presentation/widgets/google_button.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/toast_utils.dart';
import 'package:pulsetrade_app/core/utils/validators.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/register_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:pulsetrade_app/features/home/presentation/views/home_feed_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Sign-In screen matching the Figma design
///
/// This screen displays a dark-themed sign-in form with:
/// - Email/Phone number input field
/// - Password input field with visibility toggle
/// - Login button
/// - Google sign-in option
/// - Link to create a Pulse account
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String routePath = '/login';
  static const String routeName = 'login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ProviderSubscription<AsyncValue<AuthState>>? _authSubscription;
  bool _hasContactError = false;

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
        if (next.value?.isAuthenticated == true) {
          // Go to the main feed after successful login
          context.go(HomeFeedScreen.routePath);
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription?.close();
    super.dispose();
  }

  void _handleLogin() {
    final strings = AppLocalizations.of(context);
    final contact = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _hasContactError = false);

    // Check if fields are not empty
    if (contact.isEmpty || password.isEmpty) {
      setState(() => _hasContactError = true);
      showErrorToast(context, strings.pleaseEnterEmailPassword);
      return;
    }

    // Detect email vs phone based on presence of '@'
    final isEmail = contact.contains('@');

    if (isEmail) {
      // Validate email format
      if (!Validators.isValidEmail(contact)) {
        setState(() => _hasContactError = true);
        showErrorToast(context, strings.invalidEmailFormat);
        return;
      }
    } else {
      // Validate phone in +xx format
      if (!Validators.isValidPhone(contact)) {
        setState(() => _hasContactError = true);
        showErrorToast(context, strings.invalidPhoneFormat);
        return;
      }
    }

    // Proceed with login using the validated contact value
    ref.read(authControllerProvider.notifier).login(contact, password);
  }

  void _handleContactChanged(String value) {
    final contact = value.trim();

    // Clear error when user is editing
    setState(() => _hasContactError = false);

    if (contact.isEmpty) {
      return;
    }

    final isEmail = contact.contains('@');

    if (isEmail) {
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
                    // Title: "Sign in"
                    Text(strings.signIn, style: AppTextStyles.displaySmall()),
                    const SizedBox(height: 4),
                    // Subtitle: "Ready to start where you left off?"
                    Text(
                      strings.signInSubtitle,
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
                        // Password field
                        AppTextField(
                          label: strings.passwordLabel,
                          placeholder: strings.passwordPlaceholder,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: AppSpacing.fieldGap),
                        // Login button (using shared AppButton)
                        AppButton(
                          label: strings.login,
                          onPressed: _handleLogin,
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
                        // Create account link
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => context.go(RegisterScreen.routePath),
                            child: Text(
                              strings.createPulseAccount,
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
