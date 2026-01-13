import 'package:pulsetrade_app/features/trade/domain/constants/trade_constants.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';

/// Service for calculating order totals, taxes, and commissions
class OrderCalculationService {
  OrderCalculationService._();

  /// Calculate the total order value based on order type
  /// 
  /// [orderType] - The type of order (market, limit, stop, stopLimit)
  /// [value] - The input value (in currency)
  /// [price] - Current stock price
  /// [limitPrice] - Optional limit price (for limit and stopLimit orders)
  /// [stopPrice] - Optional stop price (for stop and stopLimit orders)
  /// 
  /// Returns a map with:
  /// - 'sharesValue': The total value of shares
  /// - 'numberOfShares': The number of shares
  /// - 'total': The final total including fees
  static Map<String, dynamic> calculateOrderTotal({
    required OrderType orderType,
    required double value,
    required double price,
    double? limitPrice,
    double? stopPrice,
  }) {
    final numberOfShares = (value / price).floor();
    double sharesValue = 0.0;
    double total = 0.0;

    switch (orderType) {
      case OrderType.marketOrder:
        sharesValue = value;
        total = value;
        break;
      case OrderType.limit:
        if (limitPrice != null) {
          sharesValue = numberOfShares * limitPrice;
          total = sharesValue;
        }
        break;
      case OrderType.stop:
        if (stopPrice != null) {
          sharesValue = numberOfShares * stopPrice;
          total = sharesValue;
        }
        break;
      case OrderType.stopLimit:
        if (limitPrice != null) {
          sharesValue = numberOfShares * limitPrice;
          total = sharesValue;
        }
        break;
    }

    // Calculate fees
    final commission = calculateCommission(total);
    final tax = calculateTax(total);
    total += tax; // Commission is already included (0.0 for free)

    return {
      'sharesValue': sharesValue,
      'numberOfShares': numberOfShares,
      'total': total,
      'commission': commission,
      'tax': tax,
    };
  }

  /// Calculate tax based on total order value
  static double calculateTax(double total) {
    return total * TradeConstants.taxRate;
  }

  /// Calculate commission based on total order value
  static double calculateCommission(double total) {
    return total * TradeConstants.commissionRate;
  }
}


