import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_slider.dart';
import 'package:pulsetrade_app/core/presentation/widgets/explanation_card.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/formatters.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';
import 'package:pulsetrade_app/features/trade/domain/models/order_confirmation_data.dart';
import 'package:pulsetrade_app/features/trade/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_type_tabs.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/buy_sell_toggle.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_slider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/expiration_bottom_sheet.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/stock_info_card.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/shares_balance_display.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_footer.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/choose_bucket_screen.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/confirm_order_screen.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key, this.ticker});

  static const String routePath = '/trade';
  static const String routeName = 'trade';

  final String? ticker;

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  OrderType _selectedOrderType = OrderType.marketOrder;
  bool _isBuy = true;
  double _value = 300000.0;
  final double _maxValue = 500000.0;
  final double _balance = 412032.0;
  ValueInputType _valueInputType = ValueInputType.value;

  // Limit order specific state
  double _limitPrice = 24321.0;
  ExpirationType _expirationType = ExpirationType.never;

  // Stop Limit order specific state
  double _stopPrice = 24321.0;

  StockData? _stockData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    final ticker = widget.ticker ?? 'TSLA';

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final stockDataMap = {
      'TSLA': StockData(
        ticker: 'TSLA',
        companyName: 'Tesla, Inc.',
        price: 177.12,
        change: -1.28,
        changePercentage: -1.28,
        isPositive: false,
      ),
      'NVDA': StockData(
        ticker: 'NVDA',
        companyName: 'NVIDIA Corporation',
        price: 485.22,
        change: 12.56,
        changePercentage: 2.66,
        isPositive: true,
      ),
      'MSFT': StockData(
        ticker: 'MSFT',
        companyName: 'Microsoft Corporation',
        price: 378.90,
        change: -0.45,
        changePercentage: -0.12,
        isPositive: false,
      ),
      'ANTM': StockData(
        ticker: 'ANTM',
        companyName: 'PT Aneka Tambang Tbk',
        price: 2990.0,
        change: 80.0,
        changePercentage: 2.75,
        isPositive: true,
      ),
    };

    if (mounted) {
      setState(() {
        _stockData = stockDataMap[ticker] ?? stockDataMap['TSLA']!;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _stockData == null) {
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

    final stockData = _stockData!;

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
                      executionTime: '10h 11 min',
                      onReviewOrder: _navigateToConfirmOrder,
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
        _buildPriceInput(),
        const SizedBox(height: 16),
        // Expiration
        _buildExpirationSelector(),
      ],
    );
  }

  Widget _buildPriceInput() {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              l10n.price,
              style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              Formatters.formatNumber(_limitPrice.toInt()),
              style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
            ),
          ],
        ),
        // Stacked buttons in pill-shaped container
        Container(
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Up button (light blue background)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_up,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _limitPrice = _limitPrice + 1;
                    });
                  },
                ),
              ),
              // Down button (gray background, extends upward)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_down,
                    size: 24,
                    color: AppColors.textLabel,
                  ),
                  onPressed: () {
                    setState(() {
                      _limitPrice = (_limitPrice - 1).clamp(
                        0.0,
                        double.infinity,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
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
        _buildStopPriceInput(),
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
        _buildStopPriceInput(),
        const SizedBox(height: 16),
        // Second explanation
        ExplanationCard(
          text:
              'Then, set the maximum price you are willing to pay per share', // TODO: Use l10n.stopLimitExplanation after regenerating localization
          padding: const EdgeInsets.all(AppSpacing.sm),
        ),
        const SizedBox(height: 16),
        // Limit price input
        _buildLimitPriceInput(),
        const SizedBox(height: 16),
        // Expiration
        _buildExpirationSelector(),
      ],
    );
  }

  Widget _buildStopPriceInput() {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              l10n.stop,
              style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              Formatters.formatNumber(_stopPrice.toInt()),
              style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
            ),
          ],
        ),
        // Stacked buttons in pill-shaped container
        Container(
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Up button (light blue background)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_up,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _stopPrice = _stopPrice + 1;
                    });
                  },
                ),
              ),
              // Down button (gray background)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_down,
                    size: 24,
                    color: AppColors.textLabel,
                  ),
                  onPressed: () {
                    setState(() {
                      _stopPrice = (_stopPrice - 1).clamp(0.0, double.infinity);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimitPriceInput() {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              l10n.limit,
              style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              Formatters.formatNumber(_limitPrice.toInt()),
              style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
            ),
          ],
        ),
        // Stacked buttons in pill-shaped container
        Container(
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Up button (light blue background)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_up,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _limitPrice = _limitPrice + 1;
                    });
                  },
                ),
              ),
              // Down button (gray background)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_down,
                    size: 24,
                    color: AppColors.textLabel,
                  ),
                  onPressed: () {
                    setState(() {
                      _limitPrice = (_limitPrice - 1).clamp(
                        0.0,
                        double.infinity,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
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

  void _navigateToConfirmOrder() {
    if (_stockData == null) return;

    final stockData = _stockData!;
    double sharesValue = 0.0;
    int numberOfShares = 0;
    double total = 0.0;

    // Calculate values based on order type
    // All order types now use _value as primary input
    numberOfShares = (_value / stockData.price).floor();

    if (_selectedOrderType == OrderType.marketOrder) {
      sharesValue = _value;
      total = _value;
    } else if (_selectedOrderType == OrderType.limit) {
      sharesValue = numberOfShares * _limitPrice;
      total = sharesValue;
    } else if (_selectedOrderType == OrderType.stop) {
      sharesValue = numberOfShares * _stopPrice;
      total = sharesValue;
    } else if (_selectedOrderType == OrderType.stopLimit) {
      sharesValue = numberOfShares * _limitPrice;
      total = sharesValue;
    }

    // Add commission and tax (mock values)
    const commission = 0.0; // Free
    final tax = total * 0.001; // 0.1% tax
    total += tax;

    final orderData = OrderConfirmationData(
      ticker: stockData.ticker,
      companyName: stockData.companyName,
      orderType: _selectedOrderType,
      isBuy: _isBuy,
      numberOfShares: numberOfShares,
      sharesValue: sharesValue,
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
      commission: commission,
      tax: tax,
      total: total,
    );

    context.push(ConfirmOrderScreen.routePath, extra: orderData);
  }
}
