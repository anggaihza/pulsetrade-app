import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';

/// Order confirmation data model
class OrderConfirmationData {
  final String ticker;
  final String companyName;
  final OrderType orderType;
  final bool isBuy;
  final int numberOfShares;
  final double sharesValue;
  final double? limitPrice;
  final double? stopPrice;
  final ExpirationType expirationType;
  final double commission;
  final double tax;
  final double total;

  const OrderConfirmationData({
    required this.ticker,
    required this.companyName,
    required this.orderType,
    required this.isBuy,
    required this.numberOfShares,
    required this.sharesValue,
    this.limitPrice,
    this.stopPrice,
    required this.expirationType,
    required this.commission,
    required this.tax,
    required this.total,
  });
}

