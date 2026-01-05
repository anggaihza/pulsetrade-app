import 'package:riverpod/riverpod.dart';

enum AppEnvironment { staging, production }

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.websocketUrl,
    required this.enableLogging,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String websocketUrl;
  final bool enableLogging;
}

EnvironmentConfig _resolveEnvironment() {
  const envString = String.fromEnvironment('ENV', defaultValue: 'staging');
  switch (envString) {
    case 'production':
      return const EnvironmentConfig(
        environment: AppEnvironment.production,
        apiBaseUrl: 'https://api.production.pulsetrade.app',
        websocketUrl: 'wss://ws.production.pulsetrade.app',
        enableLogging: false,
      );
    default:
      return const EnvironmentConfig(
        environment: AppEnvironment.staging,
        apiBaseUrl: 'https://api.staging.pulsetrade.app',
        websocketUrl: 'wss://ws.staging.pulsetrade.app',
        enableLogging: true,
      );
  }
}

final environmentConfigProvider = Provider<EnvironmentConfig>((ref) => _resolveEnvironment());
