import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/home_feed_provider.dart';

/// Provider for stocks news items
/// 
/// Follows clean architecture pattern:
/// - Uses existing repository interface (HomeFeedRepository)
/// - Reuses NewsItem model from domain layer
/// - Provides news items for a specific stock ticker
/// 
/// Usage:
/// ```dart
/// final newsAsync = ref.watch(stocksNewsProvider('TSLA'));
/// ```
final stocksNewsProvider = FutureProvider.family<List<NewsItem>, String>(
  (ref, ticker) async {
    final repository = ref.watch(homeFeedRepositoryProvider);
    return repository.getNewsItems(ticker);
  },
);

