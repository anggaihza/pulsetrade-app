import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/stocks/data/repositories/mock_stock_info_repository.dart';
import 'package:pulsetrade_app/features/stocks/domain/models/stock_info.dart';
import 'package:pulsetrade_app/features/stocks/domain/repositories/stock_info_repository.dart';

/// Provider for stock info repository
/// 
/// Usage:
/// ```dart
/// final repository = ref.watch(stockInfoRepositoryProvider);
/// ```
final stockInfoRepositoryProvider = Provider<StockInfoRepository>((ref) {
  return MockStockInfoRepository();
});

/// Provider for stock information by ticker
/// 
/// Usage:
/// ```dart
/// final stockInfoAsync = ref.watch(stockInfoProvider('TSLA'));
/// ```
final stockInfoProvider =
    FutureProvider.family<StockInfo, String>((ref, ticker) async {
  final repository = ref.watch(stockInfoRepositoryProvider);
  return repository.getStockInfo(ticker);
});

