import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/home_feed_provider.dart';

/// Provider for chart data by stock ticker
/// 
/// Usage:
/// ```dart
/// final chartDataAsync = ref.watch(chartDataProvider('TSLA'));
/// ```
final chartDataProvider = FutureProvider.family<List<ChartDataPoint>, String>((ref, ticker) async {
  final repository = ref.watch(homeFeedRepositoryProvider);
  return repository.getChartData(ticker);
});

/// Provider for news events by stock ticker (chart markers)
/// 
/// Usage:
/// ```dart
/// final newsEventsAsync = ref.watch(newsEventsProvider('TSLA'));
/// ```
final newsEventsProvider = FutureProvider.family<List<NewsEvent>, String>((ref, ticker) async {
  final repository = ref.watch(homeFeedRepositoryProvider);
  return repository.getNewsEvents(ticker);
});

/// Provider for news items by stock ticker (for news bottom sheet)
/// 
/// Usage:
/// ```dart
/// final newsItemsAsync = ref.watch(newsItemsProvider('TSLA'));
/// ```
final newsItemsProvider = FutureProvider.family<List<NewsItem>, String>((ref, ticker) async {
  final repository = ref.watch(homeFeedRepositoryProvider);
  return repository.getNewsItems(ticker);
});

