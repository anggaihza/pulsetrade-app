import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/home_feed_provider.dart';

/// Provider for a single feed item by index
/// 
/// This provider combines feed data with related data (comments, chart, etc.)
/// 
/// Usage:
/// ```dart
/// final itemAsync = ref.watch(feedItemProvider(index: 0));
/// ```
final feedItemProvider = FutureProvider.family<FeedItemData, int>((ref, index) async {
  // Get feed items
  final feedItems = await ref.watch(homeFeedProvider(0).future);
  
  if (index >= feedItems.length) {
    throw Exception('Feed item index out of bounds: $index');
  }
  
  final stock = feedItems[index];
  
  // Fetch related data in parallel using read() to avoid circular dependencies
  final repository = ref.read(homeFeedRepositoryProvider);
  
  final results = await Future.wait([
    repository.getComments(stock.ticker),
    repository.getChartData(stock.ticker),
    repository.getNewsEvents(stock.ticker),
    repository.getNewsItems(stock.ticker),
  ]);
  
  return FeedItemData(
    stock: stock,
    comments: results[0] as List<CommentData>,
    chartData: results[1] as List<ChartDataPoint>,
    newsEvents: results[2] as List<NewsEvent>,
    newsItems: results[3] as List<NewsItem>,
  );
});

/// Combined data model for a feed item with all related data
class FeedItemData {
  final StockData stock;
  final List<CommentData> comments;
  final List<ChartDataPoint> chartData;
  final List<NewsEvent> newsEvents;
  final List<NewsItem> newsItems;

  const FeedItemData({
    required this.stock,
    required this.comments,
    required this.chartData,
    required this.newsEvents,
    required this.newsItems,
  });
}

