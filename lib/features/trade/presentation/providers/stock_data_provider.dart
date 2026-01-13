import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/trade/domain/models/stock_data.dart';

/// Provider for fetching stock data by ticker
/// Currently uses mock data, but can be easily replaced with real API calls
final stockDataProvider = FutureProvider.family<StockData, String>(
  (ref, ticker) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Mock stock data map
    final stockDataMap = {
      'TSLA': const StockData(
        ticker: 'TSLA',
        companyName: 'Tesla, Inc.',
        price: 177.12,
        change: -1.28,
        changePercentage: -1.28,
        isPositive: false,
      ),
      'NVDA': const StockData(
        ticker: 'NVDA',
        companyName: 'NVIDIA Corporation',
        price: 485.22,
        change: 12.56,
        changePercentage: 2.66,
        isPositive: true,
      ),
      'MSFT': const StockData(
        ticker: 'MSFT',
        companyName: 'Microsoft Corporation',
        price: 378.90,
        change: -0.45,
        changePercentage: -0.12,
        isPositive: false,
      ),
      'ANTM': const StockData(
        ticker: 'ANTM',
        companyName: 'PT Aneka Tambang Tbk',
        price: 2990.0,
        change: 80.0,
        changePercentage: 2.75,
        isPositive: true,
      ),
    };

    return stockDataMap[ticker] ?? stockDataMap['TSLA']!;
  },
);


