import 'package:pulsetrade_app/features/stocks/domain/models/stock_info.dart';

/// Repository interface for stock information data
/// Abstracts data fetching to support both mock and real API implementations
abstract class StockInfoRepository {
  /// Get stock information for a specific ticker
  /// 
  /// [ticker] - The stock ticker symbol
  /// 
  /// Returns comprehensive stock information including key ratios,
  /// dividend information, and financials
  Future<StockInfo> getStockInfo(String ticker);
}

