import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_slider.dart';
import 'package:pulsetrade_app/core/presentation/widgets/explanation_card.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/domain/constants/trade_constants.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';
import 'package:pulsetrade_app/features/trade/domain/models/order_confirmation_data.dart';
import 'package:pulsetrade_app/features/trade/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/trade/domain/services/order_calculation_service.dart';
import 'package:pulsetrade_app/features/trade/presentation/providers/stock_data_provider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_type_tabs.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/buy_sell_toggle.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_slider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/stock_info_card.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/shares_balance_display.dart';
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
                    // Conditionally render Market Order or Limit view
                    if (_selectedOrderType == OrderType.marketOrder) ...[
                      ValueSlider(
                        value: _value,
                        maxValue: _maxValue,
                        numberOfShares: shares,
                        inputType: _valueInputType,
                        onInputTypeChanged: (type) {
                          setState(() {
                            _valueInputType = type;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildSlider(),
                      const SizedBox(height: AppSpacing.md),
                      SharesBalanceDisplay(
                        shares: shares,
                        value: _value,
                        inputType: _valueInputType,
                        balance: _balance,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildMarketOrderExplanation(),
                    ] else if (_selectedOrderType == OrderType.limit ||
                        _selectedOrderType == OrderType.stop ||
                        _selectedOrderType == OrderType.stopLimit) ...[
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
                    ],
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

  Widget _buildSlider() {
    return AppSlider(
      value: _value,
      min: 0,
      max: _maxValue,
      onChanged: (newValue) {
        setState(() {
          _value = newValue;
        });
      },
    );
  }

  Widget _buildMarketOrderExplanation() {
    final l10n = AppLocalizations.of(context);
    return ExplanationCard(text: l10n.marketOrderExplanation);
  }

  void _navigateToConfirmOrder(StockData stockData) {
    // Use order calculation service
    final calculation = OrderCalculationService.calculateOrderTotal(
      orderType: _selectedOrderType,
      value: _value,
      price: stockData.price,
      limitPrice:
          _selectedOrderType == OrderType.limit ||
              _selectedOrderType == OrderType.stopLimit
          ? _limitPrice
          : null,
      stopPrice:
          _selectedOrderType == OrderType.stop ||
              _selectedOrderType == OrderType.stopLimit
          ? _stopPrice
          : null,
    );

    final orderData = OrderConfirmationData(
      ticker: stockData.ticker,
      companyName: stockData.companyName,
      orderType: _selectedOrderType,
      isBuy: _isBuy,
      numberOfShares: calculation['numberOfShares'] as int,
      sharesValue: calculation['sharesValue'] as double,
      limitPrice:
          _selectedOrderType == OrderType.limit ||
              _selectedOrderType == OrderType.stopLimit
          ? _limitPrice
          : null,
      stopPrice:
          _selectedOrderType == OrderType.stop ||
              _selectedOrderType == OrderType.stopLimit
          ? _stopPrice
          : null,
      expirationType: _expirationType,
      commission: calculation['commission'] as double,
      tax: calculation['tax'] as double,
      total: calculation['total'] as double,
    );

    context.push(ConfirmOrderScreen.routePath, extra: orderData);
  }
}
