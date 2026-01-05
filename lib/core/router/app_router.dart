import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/config/environment.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/create_password_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/login_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/otp_verification_screen.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/register_screen.dart';
import 'package:pulsetrade_app/features/home/presentation/views/home_screen.dart';
import 'package:pulsetrade_app/features/settings/presentation/views/settings_screen.dart';
import 'package:pulsetrade_app/features/survey/presentation/views/survey_form_screen.dart';
import 'package:riverpod/riverpod.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;

  bool get isAuthenticated {
    final state = ref.read(authControllerProvider);
    return state.maybeWhen(data: (data) => data.isAuthenticated, orElse: () => false);
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: HomeScreen.routePath,
    debugLogDiagnostics: ref.read(environmentConfigProvider).enableLogging,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final loggingIn = state.matchedLocation == LoginScreen.routePath;
      final registering = state.matchedLocation == RegisterScreen.routePath;
      final verifyingOTP = state.matchedLocation == OTPVerificationScreen.routePath;
      final creatingPassword =
          state.matchedLocation == CreatePasswordScreen.routePath;
      final authed = notifier.isAuthenticated;
      if (!authed &&
          !(loggingIn || registering || verifyingOTP || creatingPassword)) {
        return LoginScreen.routePath;
      }
      if (authed &&
          (loggingIn || registering || verifyingOTP || creatingPassword)) {
        return HomeScreen.routePath;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: HomeScreen.routePath,
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: SurveyFormScreen.routeName,
            name: SurveyFormScreen.routeName,
            builder: (context, state) => const SurveyFormScreen(),
          ),
          GoRoute(
            path: SettingsScreen.routeName,
            name: SettingsScreen.routeName,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        name: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: OTPVerificationScreen.routePath,
        name: OTPVerificationScreen.routeName,
        builder: (context, state) {
          final contact = state.uri.queryParameters['contact'] ?? '';
          final type = state.uri.queryParameters['type'] ?? 'email';
          final verificationType = type == 'phone'
              ? VerificationType.phone
              : VerificationType.email;
          return OTPVerificationScreen(
            contact: contact,
            verificationType: verificationType,
          );
        },
      ),
      GoRoute(
        path: CreatePasswordScreen.routePath,
        name: CreatePasswordScreen.routeName,
        builder: (context, state) => const CreatePasswordScreen(),
      ),
    ],
  );
});
