import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_card.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_input.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/home/presentation/views/home_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/register_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.login)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.login,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        label: strings.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: strings.password,
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: authState.isLoading ? '...' : strings.submit,
                        onPressed: authState.isLoading
                            ? null
                            : () => ref
                                  .read(authControllerProvider.notifier)
                                  .login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.go(RegisterScreen.routePath),
                        child: Text(strings.register),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
