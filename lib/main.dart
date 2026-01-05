import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pulsetrade_app/app.dart';
import 'package:pulsetrade_app/core/storage/cache/cache_client.dart';
import 'package:pulsetrade_app/core/storage/preferences/preferences_storage.dart';
import 'package:pulsetrade_app/core/storage/secure/secure_storage.dart';
import 'package:pulsetrade_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  final cacheClient = HiveCacheClient();
  await cacheClient.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        secureStorageProvider.overrideWithValue(const SecureStorage(FlutterSecureStorage())),
        cacheClientProvider.overrideWithValue(cacheClient),
      ],
      observers: const <ProviderObserver>[RiverpodLogger()],
      child: const App(),
    ),
  );
}
