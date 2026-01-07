import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// Pure chart widget for displaying stock price data
class StockChartWidget extends StatefulWidget {
  final List<ChartDataPoint> chartData;
  final bool isExpanded;

  const StockChartWidget({
    super.key,
    required this.chartData,
    this.isExpanded = false,
  });

  @override
  State<StockChartWidget> createState() => _StockChartWidgetState();
}

class _StockChartWidgetState extends State<StockChartWidget> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      // Mini chart - just the chart visualization
      return _buildMiniChart();
    }

    // Full expanded chart - just the chart visualization
    return _buildFullChart();
  }

  Widget _buildMiniChart() {
    final spots = widget.chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullChart() {
    final spots = widget.chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final minY = widget.chartData
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);
    final maxY = widget.chartData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFF2C2C2C),
              strokeWidth: 0.5,
              dashArray: [5, 5], // Dashed line
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.labelSmall(
                    color: const Color(0xFFAEAEAE),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (widget.chartData.length / 10).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= widget.chartData.length) {
                  return const SizedBox.shrink();
                }
                final date = widget.chartData[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}',
                    style: AppTextStyles.labelSmall(
                      color: const Color(0xFFAEAEAE),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: minY - padding,
        maxY: maxY + padding,
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {
                if (touchResponse == null ||
                    touchResponse.lineBarSpots == null) {
                  setState(() {
                    _touchedIndex = null;
                  });
                  return;
                }
                setState(() {
                  _touchedIndex = touchResponse.lineBarSpots!.first.x.toInt();
                });
              },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFFFFC107),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '\$${barSpot.y.toStringAsFixed(2)}',
                  AppTextStyles.labelSmall(
                    color: AppColors.background,
                  ).copyWith(fontSize: 10),
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: const Color(0xFFAEAEAE),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: const Color(0xFFFFC107),
                          strokeWidth: 2,
                          strokeColor: AppColors.textPrimary,
                        );
                      },
                    ),
                  );
                }).toList();
              },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
