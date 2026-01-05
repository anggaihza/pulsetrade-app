// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/app.dart';
import 'package:pulsetrade_app/core/storage/cache/cache_client.dart';
import 'package:pulsetrade_app/core/storage/preferences/preferences_storage.dart';
import 'package:pulsetrade_app/core/storage/secure/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPrefs = await SharedPreferences.getInstance();
    final cache = _FakeCacheClient();
    final secureStorage = SecureStorage(FakeFlutterSecureStorage());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          secureStorageProvider.overrideWithValue(secureStorage),
          cacheClientProvider.overrideWithValue(cache),
        ],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}

class FakeFlutterSecureStorage implements FlutterSecureStorage {
  FakeFlutterSecureStorage();

  final Map<String, String> _store = <String, String>{};

  @override
  IOSOptions get iOptions => IOSOptions.defaultOptions;

  @override
  AndroidOptions get aOptions => AndroidOptions.defaultOptions;

  @override
  LinuxOptions get lOptions => LinuxOptions.defaultOptions;

  @override
  WindowsOptions get wOptions => WindowsOptions.defaultOptions;

  @override
  WebOptions get webOptions => WebOptions.defaultOptions;

  @override
  MacOsOptions get mOptions => MacOsOptions.defaultOptions;

  @override
  void registerListener({required String key, required ValueChanged<String?> listener}) {}

  @override
  void unregisterListener({required String key, required ValueChanged<String?> listener}) {}

  @override
  void unregisterAllListenersForKey({required String key}) {}

  @override
  void unregisterAllListeners() {}

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      Map<String, String>.from(_store);

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }

  @override
  Stream<bool>? get onCupertinoProtectedDataAvailabilityChanged => const Stream<bool>.empty();

  @override
  Future<bool?> isCupertinoProtectedDataAvailable() async => true;
}

class _FakeCacheClient implements CacheClient {
  final Map<String, Map<String, Object?>> _cache = <String, Map<String, Object?>>{};

  @override
  Future<void> delete(String box, String key) async {
    _cache[box]?.remove(key);
  }

  @override
  Future<void> init() async {}

  @override
  T? read<T>(String box, String key) {
    return _cache[box]?[key] as T?;
  }

  @override
  Future<void> write<T>(String box, String key, T value) async {
    _cache.putIfAbsent(box, () => <String, Object?>{})[key] = value;
  }
}
