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
import 'package:pulsetrade_app/features/trade/domain/utils/order_price_helper.dart';
import 'package:pulsetrade_app/features/trade/presentation/providers/stock_data_provider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_type_tabs.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/buy_sell_toggle.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/stock_info_card.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_footer.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/trade_loading_screen.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/trade_error_screen.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/trade_app_bar.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/add_to_bucket_button.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_type_view_builder.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/confirm_order_screen.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key, this.ticker});

  static const String routePath = '/trade';
  static const String routeName = 'trade';

  final String? ticker;

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  OrderType _selectedOrderType = OrderType.marketOrder;
  bool _isBuy = true;
  double _value = TradeConstants.defaultValue;
  final double _maxValue = TradeConstants.defaultMaxValue;
  final double _balance = TradeConstants.defaultBalance;
  ValueInputType _valueInputType = ValueInputType.value;

  // Limit order specific state
  double _limitPrice = TradeConstants.defaultLimitPrice;
  ExpirationType _expirationType = ExpirationType.never;

  // Stop Limit order specific state
  double _stopPrice = TradeConstants.defaultStopPrice;

  @override
  Widget build(BuildContext context) {
    final ticker = widget.ticker ?? 'TSLA';
    final stockDataAsync = ref.watch(stockDataProvider(ticker));

    return stockDataAsync.when(
      data: (stockData) => _buildTradeScreen(context, stockData),
      loading: () => const TradeLoadingScreen(),
      error: (error, stack) => TradeErrorScreen(error: error),
    );
  }

  Widget _buildTradeScreen(BuildContext context, StockData stockData) {
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
                    OrderTypeTabs(
                      selectedType: _selectedOrderType,
                      onTypeSelected: (type) {
                        setState(() {
                          _selectedOrderType = type;
                        });
                      },
                    ),
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
                    // Unified order type view builder (handles all order types)
                    OrderTypeViewBuilder(
                      orderType: _selectedOrderType,
                      stockData: stockData,
                      value: _value,
                      maxValue: _maxValue,
                      balance: _balance,
                      valueInputType: _valueInputType,
                      limitPrice: _limitPrice,
                      stopPrice: _stopPrice,
                      expirationType: _expirationType,
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
                      onLimitPriceChanged: (newPrice) {
                        setState(() {
                          _limitPrice = newPrice;
                        });
                      },
                      onStopPriceChanged: (newPrice) {
                        setState(() {
                          _stopPrice = newPrice;
                        });
                      },
                      onExpirationChanged: (type) {
                        setState(() {
                          _expirationType = type;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const AddToBucketButton(),
                    const SizedBox(height: AppSpacing.md),
                    OrderFooter(
                      executionTime: TradeConstants.defaultExecutionTime,
                      onReviewOrder: () => _navigateToConfirmOrder(stockData),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToConfirmOrder(StockData stockData) {
    // Get prices based on order type
    final prices = OrderPriceHelper.getOrderPrices(
      _selectedOrderType,
      _limitPrice,
      _stopPrice,
    );

    // Use order calculation service
    final calculation = OrderCalculationService.calculateOrderTotal(
      orderType: _selectedOrderType,
      value: _value,
      price: stockData.price,
      limitPrice: prices['limitPrice'],
      stopPrice: prices['stopPrice'],
    );

    final orderData = OrderConfirmationData(
      ticker: stockData.ticker,
      companyName: stockData.companyName,
      orderType: _selectedOrderType,
      isBuy: _isBuy,
      numberOfShares: calculation['numberOfShares'] as int,
      sharesValue: calculation['sharesValue'] as double,
      limitPrice: prices['limitPrice'],
      stopPrice: prices['stopPrice'],
      expirationType: _expirationType,
      commission: calculation['commission'] as double,
      tax: calculation['tax'] as double,
      total: calculation['total'] as double,
    );

    context.push(ConfirmOrderScreen.routePath, extra: orderData);
  }
}
