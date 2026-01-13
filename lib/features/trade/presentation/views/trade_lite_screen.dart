import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_slider.dart';
import 'package:pulsetrade_app/core/presentation/widgets/explanation_card.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/formatters.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/domain/constants/trade_constants.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';
import 'package:pulsetrade_app/features/trade/domain/models/order_confirmation_data.dart';
import 'package:pulsetrade_app/features/trade/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/trade/domain/services/order_calculation_service.dart';
import 'package:pulsetrade_app/features/trade/presentation/providers/stock_data_provider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/buy_sell_toggle.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/confirm_order_screen.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/stock_info_card.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/shares_balance_display.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_footer.dart';

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

  Widget _buildTradeLiteScreen(BuildContext context, StockData stockData) {
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
                    BuySellToggle(
                      isBuy: _isBuy,
                      onToggle: (isBuy) {
                        setState(() {
                          _isBuy = isBuy;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildValueSection(stockData),
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

  Widget _buildValueSection(StockData stockData) {
    final l10n = AppLocalizations.of(context);
    final shares = (_value / stockData.price).floor();

    return Container(
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  _valueInputType == ValueInputType.value
                      ? l10n.value
                      : l10n.numberOfShares,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final selectedType = await ValueInputTypeModal.show(
                      context,
                      currentType: _valueInputType,
                    );
                    if (selectedType != null) {
                      setState(() {
                        _valueInputType = selectedType;
                      });
                    }
                  },
                  child: const Icon(
                    TablerIcons.circle_caret_down,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _valueInputType == ValueInputType.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${Formatters.formatValue(_value)}',
                        style: AppTextStyles.headlineLarge(
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: 32),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'USD',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatValue(shares.toDouble()),
                        style: AppTextStyles.headlineLarge(
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: 32),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l10n.shares,
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
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
