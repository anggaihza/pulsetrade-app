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
    final targetBox = await Hive.openBox<T>(box);
    await targetBox.put(key, value);
  }

  @override
  T? read<T>(String box, String key) {
    final targetBox = Hive.isBoxOpen(box) ? Hive.box<T>(box) : null;
    return targetBox?.get(key);
  }

  @override
  Future<void> delete(String box, String key) async {
    if (!Hive.isBoxOpen(box)) return;
    final Box<dynamic> targetBox = Hive.box<dynamic>(box);
    await targetBox.delete(key);
  }
}

final cacheClientProvider = Provider<CacheClient>((ref) => throw UnimplementedError());
