import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void logInfo(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(message, name: 'PulseTrade', error: error, stackTrace: stackTrace);
}

base class RiverpodLogger extends ProviderObserver {
  const RiverpodLogger();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (!kDebugMode) return;
    final providerName = context.provider.name ?? context.provider.runtimeType.toString();
    developer.log('Provider updated', name: providerName, error: newValue);
  }
}
