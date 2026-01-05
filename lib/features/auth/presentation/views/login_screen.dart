import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_text_field.dart';
import 'package:pulsetrade_app/core/presentation/widgets/google_button.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/register_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:pulsetrade_app/features/home/presentation/views/home_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _authSubscription = ref.listenManual<AsyncValue<AuthState>>(
      authControllerProvider,
      (previous, next) {
        if (!mounted) return;
        if (next.hasError) {
          final failure = next.error;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.toString())));
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
    _passwordController.dispose();
    _authSubscription?.close();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      ref.read(authControllerProvider.notifier).login(email, password);
    }
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google sign-in functionality
    // This is a placeholder for future Google authentication integration
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
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
                  Text('Sign in', style: AppTextStyles.displaySmall()),
                  const SizedBox(height: 4),
                  // Subtitle: "Ready to start where you left off?"
                  Text(
                    'Ready to start where you left off?',
                    style: AppTextStyles.bodyLarge(
                      color: AppColors.textSecondary,
                    ),
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
                        label: 'Email/Phone number',
                        placeholder: 'Type your email/phone number',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
                      // Password field
                      AppTextField(
                        label: 'Password',
                        placeholder: 'Type your password',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
                      // Login button (using shared AppButton)
                      AppButton(
                        label: 'Login',
                        onPressed: _handleLogin,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
                      // Or divider
                      const OrDivider(),
                      const SizedBox(height: AppSpacing.fieldGap),
                      // Google sign-in button
                      GoogleButton(onPressed: _handleGoogleSignIn),
                      const SizedBox(height: AppSpacing.fieldGap),
                      // Create account link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.go(RegisterScreen.routePath),
                          child: Text(
                            'Create a Pulse account',
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
    );
  }
}
