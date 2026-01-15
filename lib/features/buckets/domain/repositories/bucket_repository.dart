import 'package:pulsetrade_app/features/buckets/domain/models/bucket.dart';

/// Repository interface for bucket data
/// Abstracts data fetching to support both mock and real API implementations
abstract class BucketRepository {
  /// Get all available buckets
  /// 
  /// Returns a list of all buckets the user has access to
  Future<List<Bucket>> getBuckets();

  /// Get buckets for a specific stock ticker
  /// 
  /// [ticker] - The stock ticker symbol
  /// 
  /// Returns buckets that contain or are related to the specified stock
  Future<List<Bucket>> getBucketsForStock(String ticker);
}

