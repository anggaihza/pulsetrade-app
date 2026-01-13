import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_slider.dart';
import 'package:pulsetrade_app/core/presentation/widgets/explanation_card.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
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
import 'package:pulsetrade_app/features/trade/presentation/widgets/expiration_bottom_sheet.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/stock_info_card.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/shares_balance_display.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_footer.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/price_input_stepper.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/choose_bucket_screen.dart';
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
      loading: () => _buildLoadingScreen(context),
      error: (error, stack) => _buildErrorScreen(context, error),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Error loading stock data: $error',
          style: AppTextStyles.bodyLarge(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildTradeScreen(BuildContext context, StockData stockData) {
    final shares = (_value / stockData.price).floor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
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
                    ] else if (_selectedOrderType == OrderType.limit) ...[
                      _buildLimitView(stockData: stockData),
                    ] else if (_selectedOrderType == OrderType.stop) ...[
                      _buildStopView(stockData: stockData),
                    ] else if (_selectedOrderType == OrderType.stopLimit) ...[
                      _buildStopLimitView(stockData: stockData),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _buildAddToBucket(),
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

  Widget _buildAddToBucket() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.push(ChooseBucketScreen.routePath);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  TablerIcons.chart_donut_filled,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.addToBucket,
                  style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
                ),
              ],
            ),
            const Icon(
              TablerIcons.chevron_right,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitView({required StockData stockData}) {
    final l10n = AppLocalizations.of(context);
    final shares = (_value / stockData.price).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
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
        // Slider for value
        _buildSlider(),
        const SizedBox(height: AppSpacing.md),
        // Value and Balance
        SharesBalanceDisplay(
          shares: shares,
          value: _value,
          inputType: _valueInputType,
          balance: _balance,
        ),
        const SizedBox(height: 16),
        // Limit explanation
        ExplanationCard(
          text: l10n.limitExplanation,
          padding: const EdgeInsets.all(AppSpacing.sm),
        ),
        const SizedBox(height: 16),
        // Price input
        PriceInputStepper(
          label: l10n.price,
          value: _limitPrice,
          onIncrement: () {
            setState(() {
              _limitPrice = _limitPrice + 1;
            });
          },
          onDecrement: () {
            setState(() {
              _limitPrice = (_limitPrice - 1).clamp(0.0, double.infinity);
            });
          },
        ),
        const SizedBox(height: 16),
        // Expiration
        _buildExpirationSelector(),
      ],
    );
  }

  Widget _buildStopView({required StockData stockData}) {
    final l10n = AppLocalizations.of(context);
    final shares = (_value / stockData.price).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
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
        // Slider for value
        _buildSlider(),
        const SizedBox(height: AppSpacing.md),
        // Value and Balance
        SharesBalanceDisplay(
          shares: shares,
          value: _value,
          inputType: _valueInputType,
          balance: _balance,
        ),
        const SizedBox(height: 16),
        // Explanation
        ExplanationCard(
          text: l10n.limitExplanation,
          padding: const EdgeInsets.all(AppSpacing.sm),
        ),
        const SizedBox(height: 16),
        // Stop price input
        PriceInputStepper(
          label: l10n.stop,
          value: _stopPrice,
          onIncrement: () {
            setState(() {
              _stopPrice = _stopPrice + 1;
            });
          },
          onDecrement: () {
            setState(() {
              _stopPrice = (_stopPrice - 1).clamp(0.0, double.infinity);
            });
          },
        ),
        const SizedBox(height: 16),
        // Expiration
        _buildExpirationSelector(),
      ],
    );
  }

  Widget _buildStopLimitView({required StockData stockData}) {
    final l10n = AppLocalizations.of(context);
    final shares = (_value / stockData.price).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
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
        // Slider for value
        _buildSlider(),
        const SizedBox(height: AppSpacing.md),
        // Value and Balance
        SharesBalanceDisplay(
          shares: shares,
          value: _value,
          inputType: _valueInputType,
          balance: _balance,
        ),
        const SizedBox(height: 16),
        // First explanation
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            l10n.limitExplanation,
            style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        // Stop price input
        PriceInputStepper(
          label: l10n.stop,
          value: _stopPrice,
          onIncrement: () {
            setState(() {
              _stopPrice = _stopPrice + 1;
            });
          },
          onDecrement: () {
            setState(() {
              _stopPrice = (_stopPrice - 1).clamp(0.0, double.infinity);
            });
          },
        ),
        const SizedBox(height: 16),
        // Second explanation
        const ExplanationCard(
          text:
              'Then, set the maximum price you are willing to pay per share', // TODO: Use l10n.stopLimitExplanation after regenerating localization
          padding: EdgeInsets.all(AppSpacing.sm),
        ),
        const SizedBox(height: 16),
        // Limit price input
        PriceInputStepper(
          label: l10n.limit,
          value: _limitPrice,
          onIncrement: () {
            setState(() {
              _limitPrice = _limitPrice + 1;
            });
          },
          onDecrement: () {
            setState(() {
              _limitPrice = (_limitPrice - 1).clamp(0.0, double.infinity);
            });
          },
        ),
        const SizedBox(height: 16),
        // Expiration
        _buildExpirationSelector(),
      ],
    );
  }

  Widget _buildExpirationSelector() {
    final l10n = AppLocalizations.of(context);
    final expirationText = _expirationType == ExpirationType.never
        ? l10n.never
        : l10n.endOfDay;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final result = await ExpirationBottomSheet.show(
          context,
          currentType: _expirationType,
        );
        if (result != null) {
          setState(() {
            _expirationType = result;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  TablerIcons.clock,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.expiration,
                  style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  expirationText,
                  style: AppTextStyles.labelMedium(color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  TablerIcons.chevron_right,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
