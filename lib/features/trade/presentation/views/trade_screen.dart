import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/order_type_tabs.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/buy_sell_toggle.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_slider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/expiration_bottom_sheet.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/choose_bucket_screen.dart';

class _TradeStockData {
  final String ticker;
  final String companyName;
  final double price;
  final double change;
  final double changePercentage;
  final bool isPositive;

  _TradeStockData({
    required this.ticker,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercentage,
    required this.isPositive,
  });
}

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
  int _numberOfShares = 21123;
  double _limitPrice = 24321.0;
  ExpirationType _expirationType = ExpirationType.never;

  // Stop Limit order specific state
  double _stopPrice = 24321.0;

  _TradeStockData? _stockData;
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
      'TSLA': _TradeStockData(
        ticker: 'TSLA',
        companyName: 'Tesla, Inc.',
        price: 177.12,
        change: -1.28,
        changePercentage: -1.28,
        isPositive: false,
      ),
      'NVDA': _TradeStockData(
        ticker: 'NVDA',
        companyName: 'NVIDIA Corporation',
        price: 485.22,
        change: 12.56,
        changePercentage: 2.66,
        isPositive: true,
      ),
      'MSFT': _TradeStockData(
        ticker: 'MSFT',
        companyName: 'Microsoft Corporation',
        price: 378.90,
        change: -0.45,
        changePercentage: -0.12,
        isPositive: false,
      ),
      'ANTM': _TradeStockData(
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
                    _buildStockInfo(
                      ticker: stockData.ticker,
                      companyName: stockData.companyName,
                      price: stockData.price,
                      change: stockData.change,
                      changePercentage: stockData.changePercentage,
                      isPositive: stockData.isPositive,
                    ),
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
                      _buildSharesAndBalance(shares: shares),
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
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            _buildOrderFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo({
    required String ticker,
    required String companyName,
    required double price,
    required double change,
    required double changePercentage,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.whiteNormal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticker,
                  style: AppTextStyles.titleSmall(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  companyName,
                  style: AppTextStyles.bodySmall(color: AppColors.textLabel),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_formatPrice(price)}',
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}',
                    style: AppTextStyles.bodyMedium(
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(2)}% ${AppLocalizations.of(context).today}',
                    style: AppTextStyles.bodyMedium(
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return SizedBox(
      width: double.infinity,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 0.5,
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.textPrimary,
          thumbColor: Colors.transparent,
          overlayColor: Colors.transparent,
          trackShape: const _FullWidthSliderTrackShape(),
          thumbShape: const _CustomSliderThumb(enabledThumbRadius: 8.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
        ),
        child: Slider(
          value: _value,
          min: 0,
          max: _maxValue,
          onChanged: (newValue) {
            setState(() {
              _value = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSharesSlider() {
    const maxShares = 50000;
    return SizedBox(
      width: double.infinity,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 0.5,
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.textPrimary,
          thumbColor: Colors.transparent,
          overlayColor: Colors.transparent,
          trackShape: const _FullWidthSliderTrackShape(),
          thumbShape: const _CustomSliderThumb(enabledThumbRadius: 8.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
        ),
        child: Slider(
          value: _numberOfShares.toDouble(),
          min: 0,
          max: maxShares.toDouble(),
          onChanged: (newValue) {
            setState(() {
              _numberOfShares = newValue.toInt();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSharesAndBalance({required int shares}) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${l10n.shares} : ',
              style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatNumber(shares),
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${l10n.balance} : ',
              style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '\$${_formatNumber(_balance.toInt())}',
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketOrderExplanation() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.marketOrderExplanation,
        style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
        textAlign: TextAlign.center,
      ),
    );
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

  Widget _buildLimitView({required _TradeStockData stockData}) {
    final l10n = AppLocalizations.of(context);
    final limitValue = _numberOfShares * _limitPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
        ValueSlider(
          value: limitValue,
          maxValue: _maxValue,
          numberOfShares: _numberOfShares,
          inputType: _valueInputType,
          onInputTypeChanged: (type) {
            setState(() {
              _valueInputType = type;
            });
          },
        ),
        const SizedBox(height: 16),
        // Slider for shares
        _buildSharesSlider(),
        const SizedBox(height: 16),
        // Value and Balance
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${l10n.value}: ',
                  style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
                ),
                Text(
                  '\$${_formatNumber(limitValue.toInt())}',
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.balance}: ',
                  style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
                ),
                Text(
                  _formatNumber(_balance.toInt()),
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Limit explanation
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
              _formatNumber(_limitPrice.toInt()),
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

  Widget _buildStopView({required _TradeStockData stockData}) {
    final l10n = AppLocalizations.of(context);
    final stopValue = _numberOfShares * _stopPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
        ValueSlider(
          value: stopValue,
          maxValue: _maxValue,
          numberOfShares: _numberOfShares,
          inputType: _valueInputType,
          onInputTypeChanged: (type) {
            setState(() {
              _valueInputType = type;
            });
          },
        ),
        const SizedBox(height: 16),
        // Slider for shares
        _buildSharesSlider(),
        const SizedBox(height: 16),
        // Value and Balance
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${l10n.value}: ',
                  style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
                ),
                Text(
                  '\$${_formatNumber(stopValue.toInt())}',
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.balance}: ',
                  style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
                ),
                Text(
                  _formatNumber(_balance.toInt()),
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Explanation
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
        // Expiration
        _buildExpirationSelector(),
      ],
    );
  }

  Widget _buildStopLimitView({required _TradeStockData stockData}) {
    final l10n = AppLocalizations.of(context);
    final stopLimitValue = _numberOfShares * _limitPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
        ValueSlider(
          value: stopLimitValue,
          maxValue: _maxValue,
          numberOfShares: _numberOfShares,
          inputType: _valueInputType,
          onInputTypeChanged: (type) {
            setState(() {
              _valueInputType = type;
            });
          },
        ),
        const SizedBox(height: 16),
        // Slider for shares
        _buildSharesSlider(),
        const SizedBox(height: 16),
        // Value and Balance
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${l10n.value}: ',
                  style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
                ),
                Text(
                  '\$${_formatNumber(stopLimitValue.toInt())}',
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.balance}: ',
                  style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
                ),
                Text(
                  _formatNumber(_balance.toInt()),
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
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
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            'Then, set the maximum price you are willing to pay per share', // TODO: Use l10n.stopLimitExplanation after regenerating localization
            style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
            textAlign: TextAlign.center,
          ),
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
              _formatNumber(_stopPrice.toInt()),
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
              _formatNumber(_limitPrice.toInt()),
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

  Widget _buildOrderFooter() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: l10n.orderExecutionMessage,
              style: AppTextStyles.bodySmall(
                color: AppColors.textLabel,
              ).copyWith(fontSize: 10),
              children: [
                TextSpan(
                  text: '10h 11 min',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.primary,
                  ).copyWith(fontSize: 10),
                ),
              ],
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: AppSpacing.md - AppSpacing.xs),
          AppButton(
            label: l10n.reviewOrder,
            onPressed: () {
              // TODO: Navigate to review order screen
            },
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(1).split('.');
    final integerPart = int.parse(parts[0]);
    return '${integerPart.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}.${parts[1]}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _FullWidthSliderTrackShape extends SliderTrackShape {
  const _FullWidthSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme?.trackHeight ?? 0.0;
    final thumbRadius = 8.0;
    final trackLeft = thumbRadius;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - (2 * thumbRadius);
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 0.0;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final visualTrackLeft = 0.0;
    final visualTrackWidth = parentBox.size.width;

    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? AppColors.textLabel
      ..style = PaintingStyle.fill;

    context.canvas.drawRect(
      Rect.fromLTWH(visualTrackLeft, trackTop, visualTrackWidth, trackHeight),
      inactivePaint,
    );

    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? AppColors.primary
      ..style = PaintingStyle.fill;

    final activeWidth = (thumbCenter.dx - visualTrackLeft).clamp(
      0.0,
      visualTrackWidth,
    );
    if (activeWidth > 0) {
      context.canvas.drawRect(
        Rect.fromLTWH(visualTrackLeft, trackTop, activeWidth, trackHeight),
        activePaint,
      );
    }
  }
}

class _CustomSliderThumb extends SliderComponentShape {
  final double enabledThumbRadius;

  const _CustomSliderThumb({required this.enabledThumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    canvas.drawCircle(
      center,
      enabledThumbRadius,
      Paint()
        ..color = AppColors.background
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      enabledThumbRadius,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }
}
