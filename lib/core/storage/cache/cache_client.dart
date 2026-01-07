import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

abstract class CacheClient {
  Future<void> init();

  Future<void> write<T>(String box, String key, T value);

  T? read<T>(String box, String key);

  Future<void> delete(String box, String key);
}

class HiveCacheClient implements CacheClient {
  @override
  Future<void> init() async {
    await Hive.openBox<dynamic>('appCache');
  }

  @override
  Future<void> write<T>(String box, String key, T value) async {
    final targetBox = Hive.isBoxOpen(box) 
        ? Hive.box<dynamic>(box) 
        : await Hive.openBox<dynamic>(box);
    await targetBox.put(key, value);
  }

  @override
  T? read<T>(String box, String key) {
    if (!Hive.isBoxOpen(box)) return null;
    final targetBox = Hive.box<dynamic>(box);
    final value = targetBox.get(key);
    return value as T?;
  }

  @override
  Future<void> delete(String box, String key) async {
    if (!Hive.isBoxOpen(box)) return;
    final targetBox = Hive.box<dynamic>(box);
    await targetBox.delete(key);
  }
}

final cacheClientProvider = Provider<CacheClient>((ref) => throw UnimplementedError());
