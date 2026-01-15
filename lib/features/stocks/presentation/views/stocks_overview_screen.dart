import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/home_feed_provider.dart';
import 'package:pulsetrade_app/features/stocks/presentation/providers/stocks_chart_data_provider.dart';
import 'package:pulsetrade_app/features/stocks/presentation/widgets/stocks_chart_widget.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/trade_screen.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/bottom_navigation_bar.dart';

/// Stocks Overview Screen - Detailed view of a stock
class StocksOverviewScreen extends ConsumerStatefulWidget {
  final String? ticker;

  const StocksOverviewScreen({super.key, this.ticker});

  static const String routePath = '/stocks';
  static const String routeName = 'stocks';

  @override
  ConsumerState<StocksOverviewScreen> createState() =>
      _StocksOverviewScreenState();
}

class _StocksOverviewScreenState extends ConsumerState<StocksOverviewScreen> {
  String _selectedTimeRange = '1D';
  String _selectedTab = 'Overview';

  final List<String> _timeRanges = [
    '1D',
    '1W',
    '1M',
    '3M',
    '6M',
    'YTD',
    '1Y',
    '5Y',
    'All',
  ];

  final List<String> _tabs = ['Overview', 'Info', 'News', 'Buckets'];

  @override
  Widget build(BuildContext context) {
    // For now, use the first stock from feed as default
    // In production, fetch stock by ticker
    final feedAsync = ref.watch(homeFeedProvider(0));
    final stock = feedAsync.maybeWhen(
      data: (List<StockData> stocks) => stocks.isNotEmpty
          ? stocks.firstWhere(
              (StockData s) =>
                  widget.ticker == null || s.ticker == widget.ticker,
              orElse: () => stocks.first,
            )
          : null,
      orElse: () => null,
    );

    if (stock == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Stock not found',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: const BoxDecoration(color: AppColors.background),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      TablerIcons.arrow_narrow_left,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement bookmark functionality
                  },
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      TablerIcons.bookmarks_filled,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Title Section
              _buildStockTitle(stock),
              const SizedBox(height: AppSpacing.md),

              // Chart Section
              _buildChartSection(stock.ticker),

              const SizedBox(height: AppSpacing.md),

              // Time Range Selector
              _buildTimeRangeSelector(),

              const SizedBox(height: AppSpacing.md),

              // Buy/Sell Buttons
              _buildBuySellButtons(stock),

              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.surface, height: 0.5),
              const SizedBox(height: AppSpacing.md),

              // Filter Tabs
              _buildFilterTabs(),

              const SizedBox(height: AppSpacing.md),

              // Content based on selected tab
              _buildTabContent(stock),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: 3, // Watchlist tab
        onTap: (index) {
          // TODO: Implement navigation
        },
      ),
    );
  }

  Widget _buildStockTitle(StockData stock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo and ticker
        Row(
          children: [
            // Stock logo placeholder (circle with ticker initial)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: Center(
                child: Text(
                  stock.ticker.substring(0, 1),
                  style: AppTextStyles.titleMedium(color: AppColors.background),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.ticker, style: AppTextStyles.titleMedium()),
                const SizedBox(height: 4),
                Text(
                  '${stock.ticker} Inc.', // TODO: Get company name from stock data
                  style: AppTextStyles.bodySmall(color: AppColors.textLabel),
                ),
              ],
            ),
          ],
        ),
        // Price and change
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${stock.price.toStringAsFixed(2)}',
              style: AppTextStyles.titleMedium(),
            ),
            const SizedBox(height: 4),
            Text(
              '${stock.isPositive ? '+' : ''}\$${stock.change.toStringAsFixed(2)} (${stock.changePercentage.toStringAsFixed(2)}%) today',
              style: AppTextStyles.bodySmall(
                color: stock.isPositive ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(String ticker) {
    final chartData = ref.watch(stocksChartDataProvider(ticker));

    return StocksChartWidget(chartData: chartData);
  }

  Widget _buildTimeRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: _timeRanges.map((range) {
          final isSelected = _selectedTimeRange == range;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeRange = range;
              });
              // TODO: Fetch chart data for selected time range
            },
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  range,
                  style:
                      AppTextStyles.labelSmall(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textLabel,
                      ).copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBuySellButtons(StockData stock) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.push('${TradeScreen.routePath}?ticker=${stock.ticker}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Buy',
              style: AppTextStyles.labelMedium(color: AppColors.background),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to sell screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sell',
              style: AppTextStyles.labelMedium(color: AppColors.background),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = tab;
              });
            },
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 32, // Ensure consistent height
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (tab == 'Overview'
                          ? const Color(0xFF0E2A59) // Foundation/Primary/Darker
                          : AppColors.surface)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  tab,
                  style:
                      AppTextStyles.labelMedium(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textLabel,
                      ).copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(StockData stock) {
    switch (_selectedTab) {
      case 'Overview':
        return _buildOverviewContent(stock);
      case 'Info':
        return _buildInfoContent();
      case 'News':
        return _buildNewsContent();
      case 'Buckets':
        return _buildBucketsContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewContent(StockData stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Investment Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('My Investment', style: AppTextStyles.titleSmall()),
              const SizedBox(height: 16),
              // Donut chart
              _buildInvestmentDonut(
                progress: 0.22,
                sharesText: '21.597 shares',
                valueText: '\$1,809.63',
              ),
              const SizedBox(height: 16),
              // Investment details
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.errorDarker,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$0.50 (-2.5%)',
                      style: AppTextStyles.labelSmall(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Investment stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Average price', style: AppTextStyles.bodySmall()),
                  Text(
                    '\$112.89 (IDR 1.811 M)',
                    style: AppTextStyles.bodySmall().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current price', style: AppTextStyles.bodySmall()),
                  Text(
                    '-\$87.52 (4.61%)',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.error,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Pending Order Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Order', style: AppTextStyles.titleSmall()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successDarker,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BUY',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('\$200.000', style: AppTextStyles.labelMedium()),
                    ],
                  ),
                  Row(
                    children: [
                      Text('MARKET', style: AppTextStyles.labelSmall()),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          // TODO: Cancel order
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvestmentDonut({
    required double progress,
    required String sharesText,
    required String valueText,
  }) {
    // Card is AppColors.surface (dark). Ring in screenshot is light grey + blue arc.
    const ringBg = Color(0xFFBDBDBD); // light grey ring
    const ringWidth = 16.0;

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring + blue arc
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: ringWidth,
              backgroundColor: ringBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              strokeCap:
                  StrokeCap.butt, // looks closer to screenshot (flat ends)
            ),
          ),

          // Center texts
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sharesText,
                style: AppTextStyles.bodySmall(color: AppColors.textLabel),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                valueText,
                style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContent() {
    return const Center(
      child: Text(
        'Info content coming soon',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildNewsContent() {
    return const Center(
      child: Text(
        'News content coming soon',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildBucketsContent() {
    return const Center(
      child: Text(
        'Buckets content coming soon',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

/// Creates pie chart sections for investment donut chart
List<PieChartSectionData> _createInvestmentSections() {
  // Investment segment (blue) - approximately 22% based on Figma design
  // The blue segment appears in the upper right portion
  const investmentValue = 22.0;
  const remainingValue = 78.0;

  return [
    // Investment segment (blue) - starts from top
    PieChartSectionData(
      value: investmentValue,
      color: AppColors.primary,
      radius: 89.7575, // Half of 179.515
      showTitle: false,
      borderSide: BorderSide.none,
    ),
    // Remaining segment (gray)
    PieChartSectionData(
      value: remainingValue,
      color: AppColors.surface,
      radius: 89.7575,
      showTitle: false,
      borderSide: BorderSide.none,
    ),
  ];
}
