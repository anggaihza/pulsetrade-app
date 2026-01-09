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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildStockInfo(
                      ticker: stockData.ticker,
                      companyName: stockData.companyName,
                      price: stockData.price,
                      change: stockData.change,
                      changePercentage: stockData.changePercentage,
                      isPositive: stockData.isPositive,
                    ),
                    const SizedBox(height: 16),
                    OrderTypeTabs(
                      selectedType: _selectedOrderType,
                      onTypeSelected: (type) {
                        setState(() {
                          _selectedOrderType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    BuySellToggle(
                      isBuy: _isBuy,
                      onToggle: (isBuy) {
                        setState(() {
                          _isBuy = isBuy;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueSlider(
                      value: _value,
                      maxValue: _maxValue,
                      inputType: _valueInputType,
                      onInputTypeChanged: (type) {
                        setState(() {
                          _valueInputType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(),
                    const SizedBox(height: 16),
                    _buildSharesAndBalance(shares: shares),
                    const SizedBox(height: 16),
                    _buildMarketOrderExplanation(),
                    const SizedBox(height: 16),
                    _buildAddToBucket(),
                    const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticker,
                  style: AppTextStyles.titleSmall(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
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
                  const SizedBox(width: 4),
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
            const SizedBox(width: 4),
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
            const SizedBox(width: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      onTap: () {
        context.push(ChooseBucketScreen.routePath);
      },
      child: Container(
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
                const SizedBox(width: 8),
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

  Widget _buildOrderFooter() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
          const SizedBox(height: 12),
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
      ..color = sliderTheme.inactiveTrackColor ?? Colors.grey
      ..style = PaintingStyle.fill;

    context.canvas.drawRect(
      Rect.fromLTWH(visualTrackLeft, trackTop, visualTrackWidth, trackHeight),
      inactivePaint,
    );

    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? Colors.blue
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
