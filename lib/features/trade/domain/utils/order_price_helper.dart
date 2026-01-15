import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';

/// Utility class for determining which prices to use based on order type
///
/// Centralizes the conditional logic for limitPrice and stopPrice,
/// providing a single source of truth for price determination.
class OrderPriceHelper {
  /// Determines which prices should be used for a given order type
  ///
  /// Returns a map with 'limitPrice' and 'stopPrice' keys.
  /// Values are null if the price type is not applicable to the order type.
  ///
  /// Rules:
  /// - Market Order: Both prices are null
  /// - Limit Order: limitPrice is used, stopPrice is null
  /// - Stop Order: stopPrice is used, limitPrice is null
  /// - Stop Limit Order: Both prices are used
  static Map<String, double?> getOrderPrices(
    OrderType orderType,
    double? limitPrice,
    double? stopPrice,
  ) {
    switch (orderType) {
      case OrderType.marketOrder:
        return {
          'limitPrice': null,
          'stopPrice': null,
        };
      case OrderType.limit:
        return {
          'limitPrice': limitPrice,
          'stopPrice': null,
        };
      case OrderType.stop:
        return {
          'limitPrice': null,
          'stopPrice': stopPrice,
        };
      case OrderType.stopLimit:
        return {
          'limitPrice': limitPrice,
          'stopPrice': stopPrice,
        };
    }
  }
}

