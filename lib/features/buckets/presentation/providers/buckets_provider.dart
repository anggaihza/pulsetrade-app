import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/buckets/data/repositories/mock_bucket_repository.dart';
import 'package:pulsetrade_app/features/buckets/domain/models/bucket.dart';
import 'package:pulsetrade_app/features/buckets/domain/repositories/bucket_repository.dart';

/// Provider for bucket repository
/// 
/// Usage:
/// ```dart
/// final repository = ref.watch(bucketRepositoryProvider);
/// ```
final bucketRepositoryProvider = Provider<BucketRepository>((ref) {
  return MockBucketRepository();
});

/// Provider for all buckets
/// 
/// Usage:
/// ```dart
/// final bucketsAsync = ref.watch(bucketsProvider);
/// ```
final bucketsProvider = FutureProvider<List<Bucket>>((ref) async {
  final repository = ref.watch(bucketRepositoryProvider);
  return repository.getBuckets();
});

/// Provider for buckets filtered by stock ticker
/// 
/// Usage:
/// ```dart
/// final bucketsAsync = ref.watch(bucketsForStockProvider('TSLA'));
/// ```
final bucketsForStockProvider =
    FutureProvider.family<List<Bucket>, String>((ref, ticker) async {
  final repository = ref.watch(bucketRepositoryProvider);
  return repository.getBucketsForStock(ticker);
});

