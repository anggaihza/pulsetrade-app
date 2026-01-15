import 'package:flutter/material.dart';
import 'package:pulsetrade_app/features/buckets/domain/models/bucket.dart';
import 'package:pulsetrade_app/features/buckets/domain/repositories/bucket_repository.dart';

/// Mock implementation of BucketRepository
/// Provides sample bucket data for development and testing
class MockBucketRepository implements BucketRepository {
  @override
  Future<List<Bucket>> getBuckets() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return [
      Bucket(
        id: '1',
        name: 'Financial Bucket',
        priceChange: 0.50,
        priceChangePercent: 2.5,
        isPositive: true,
        isPublic: true,
        bookmarksCount: 12,
        checkmarksCount: 24,
        avatarColor: const Color(0xFFFFC2B8),
        imageAsset: 'assets/images/financial-bucket.png',
      ),
      Bucket(
        id: '2',
        name: 'Tourism Bucket',
        priceChange: 0.50,
        priceChangePercent: -2.5,
        isPositive: false,
        isPublic: false,
        avatarColor: const Color(0xFFFFD4B8),
        imageAsset: 'assets/images/tourism-bucket.png',
      ),
      Bucket(
        id: '3',
        name: 'Technology Bucket',
        priceChange: 0.50,
        priceChangePercent: -2.5,
        isPositive: false,
        isPublic: false,
        avatarColor: const Color(0xFFDAD0FC),
        imageAsset: 'assets/images/tech-bucket.png',
      ),
      Bucket(
        id: '4',
        name: 'Financial Bucket',
        priceChange: 0.50,
        priceChangePercent: 2.5,
        isPositive: true,
        isPublic: true,
        bookmarksCount: 12,
        checkmarksCount: 24,
        avatarColor: const Color(0xFFFFC2B8),
        imageAsset: 'assets/images/financial-bucket.png',
      ),
    ];
  }

  @override
  Future<List<Bucket>> getBucketsForStock(String ticker) async {
    // For now, return all buckets
    // In production, filter by stock ticker
    return getBuckets();
  }
}

