import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/features/trade/domain/constants/trade_constants.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';
import 'package:pulsetrade_app/features/trade/domain/models/order_confirmation_data.dart';
import 'package:pulsetrade_app/features/trade/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/trade/domain/services/order_calculation_service.dart';
import 'package:pulsetrade_app/features/trade/presentation/providers/stock_data_provider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/buy_sell_toggle.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/stock_info_card.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_footer.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/trade_loading_screen.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/trade_error_screen.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/trade_app_bar.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/market_order_view.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/confirm_order_screen.dart';

class TradeLiteScreen extends ConsumerStatefulWidget {
  const TradeLiteScreen({super.key, this.ticker});

  static const String routePath = '/trade-lite';
  static const String routeName = 'trade-lite';

  final String? ticker;

  @override
  ConsumerState<TradeLiteScreen> createState() => _TradeLiteScreenState();
}

class _TradeLiteScreenState extends ConsumerState<TradeLiteScreen> {
  bool _isBuy = true;
  double _value = TradeConstants.defaultValue;
  final double _maxValue = TradeConstants.defaultMaxValue;
  final double _balance = TradeConstants.defaultBalance;
  ValueInputType _valueInputType = ValueInputType.value;

  @override
  Widget build(BuildContext context) {
    final ticker = widget.ticker ?? 'TSLA';
    final stockDataAsync = ref.watch(stockDataProvider(ticker));

    return stockDataAsync.when(
      data: (stockData) => _buildTradeLiteScreen(context, stockData),
      loading: () => const TradeLoadingScreen(),
      error: (error, stack) => TradeErrorScreen(error: error),
    );
  }

  Widget _buildTradeLiteScreen(BuildContext context, StockData stockData) {
    final shares = (_value / stockData.price).floor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TradeAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    StockInfoCard(stockData: stockData),
                    const SizedBox(height: AppSpacing.md),
                    BuySellToggle(
                      isBuy: _isBuy,
                      onToggle: (isBuy) {
                        setState(() {
                          _isBuy = isBuy;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MarketOrderView(
                      value: _value,
                      maxValue: _maxValue,
                      numberOfShares: shares,
                      valueInputType: _valueInputType,
                      balance: _balance,
                      stockPrice: stockData.price,
                      onValueChanged: (newValue) {
                        setState(() {
                          _value = newValue;
                        });
                      },
                      onInputTypeChanged: (type) {
                        setState(() {
                          _valueInputType = type;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: OrderFooter(
                executionTime: TradeConstants.defaultExecutionTime,
                onReviewOrder: () => _navigateToConfirmOrder(stockData),
                isFloating: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToConfirmOrder(StockData stockData) {
    // Use order calculation service
    final calculation = OrderCalculationService.calculateOrderTotal(
      orderType: OrderType.marketOrder,
      value: _value,
      price: stockData.price,
    );

    final orderData = OrderConfirmationData(
      ticker: stockData.ticker,
      companyName: stockData.companyName,
      orderType: OrderType.marketOrder,
      isBuy: _isBuy,
      numberOfShares: calculation['numberOfShares'] as int,
      sharesValue: calculation['sharesValue'] as double,
      limitPrice: null,
      stopPrice: null,
      expirationType: ExpirationType.never,
      commission: calculation['commission'] as double,
      tax: calculation['tax'] as double,
      total: calculation['total'] as double,
    );

    context.push(ConfirmOrderScreen.routePath, extra: orderData);
  }
}
