import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/home/data/repositories/mock_home_feed_repository.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/domain/repositories/home_feed_repository.dart';

/// Provider for home feed repository
/// Can be easily swapped with real API implementation
final homeFeedRepositoryProvider = Provider<HomeFeedRepository>((ref) {
  return MockHomeFeedRepository();
});

/// Provider for home feed items with pagination support
/// 
/// Usage:
/// ```dart
/// final feedAsync = ref.watch(homeFeedProvider(page: 0));
/// ```
final homeFeedProvider = FutureProvider.family<List<StockData>, int>((ref, page) async {
  final repository = ref.watch(homeFeedRepositoryProvider);
  return repository.getFeedItems(page: page, limit: 10);
});

