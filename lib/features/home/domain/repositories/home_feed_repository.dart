import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// Repository interface for home feed data
/// Abstracts data fetching to support both mock and real API implementations
abstract class HomeFeedRepository {
  /// Get feed items (stock data) with pagination support
  /// 
  /// [page] - Page number (0-indexed)
  /// [limit] - Number of items per page
  /// 
  /// Returns a list of StockData items for the requested page
  Future<List<StockData>> getFeedItems({
    int page = 0,
    int limit = 10,
  });

  /// Get comments for a specific stock
  /// 
  /// [stockId] - The ticker symbol or stock ID
  /// 
  /// Returns a list of comments for the stock
  Future<List<CommentData>> getComments(String stockId);

  /// Get chart data for a specific stock
  /// 
  /// [ticker] - The stock ticker symbol
  /// 
  /// Returns a list of chart data points
  Future<List<ChartDataPoint>> getChartData(String ticker);

  /// Get news events for a specific stock (markers on chart)
  /// 
  /// [ticker] - The stock ticker symbol
  /// 
  /// Returns a list of news events
  Future<List<NewsEvent>> getNewsEvents(String ticker);

  /// Get news items for a specific stock (for news bottom sheet)
  /// 
  /// [ticker] - The stock ticker symbol
  /// 
  /// Returns a list of news items
  Future<List<NewsItem>> getNewsItems(String ticker);
}

