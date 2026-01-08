import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// Pure chart widget for displaying stock price data
class StockChartWidget extends StatefulWidget {
  final List<ChartDataPoint> chartData;
  final bool isExpanded;
  final List<NewsEvent>?
  newsEvents; // Optional news events to display as markers
  final void Function(NewsEvent)?
  onNewsEventTap; // Callback when news marker is tapped

  const StockChartWidget({
    super.key,
    required this.chartData,
    this.isExpanded = false,
    this.newsEvents,
    this.onNewsEventTap,
  });

  @override
  State<StockChartWidget> createState() => _StockChartWidgetState();
}

class _StockChartWidgetState extends State<StockChartWidget> {
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
            dotData: const FlDotData(
              show: false,
            ), // Mini chart doesn't show news events
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.0),
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

    // Vertical lines will be drawn as custom overlays to control their height
    // (We'll draw them from bottom of chart to bottom of circle)

    // Build dot data for news event markers - circle border only (transparent fill)
    final newsEventDotData =
        widget.newsEvents != null && widget.newsEvents!.isNotEmpty
        ? FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // Check if this index matches any news event
              final isNewsEvent = widget.newsEvents!.any(
                (event) => event.chartIndex == index,
              );
              if (isNewsEvent) {
                // Draw circle with border only (transparent fill, 2px yellow border)
                // Smaller circle: 20px diameter (10px radius)
                return FlDotCirclePainter(
                  radius: 8.5,
                  color: Colors.transparent, // Transparent fill
                  strokeWidth: 2,
                  strokeColor: AppColors.warning, // Yellow border
                );
              }
              return FlDotCirclePainter(radius: 0, color: Colors.transparent);
            },
          )
        : const FlDotData(show: false);

    return Stack(
      children: [
        LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.surface,
                  strokeWidth: 0.5,
                  dashArray: const [5, 5], // Dashed line
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
                        color: AppColors.textLabel,
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
                          color: AppColors.textLabel,
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
                      setState(() {});
                      return;
                    }
                    setState(() {
                      // Touch detected - could be used for future interactions
                    });
                  },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => AppColors.warning,
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
                          color: AppColors.textLabel,
                          strokeWidth: 1,
                          dashArray: const [5, 5],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: AppColors.warning,
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
                dotData: newsEventDotData,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Overlay custom vertical dashed lines and icons for news event markers
        if (widget.newsEvents != null && widget.newsEvents!.isNotEmpty)
          ...widget.newsEvents!.map((event) {
            if (event.chartIndex < 0 ||
                event.chartIndex >= widget.chartData.length) {
              return const SizedBox.shrink();
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                // Get the exact spot from the chart data
                final spot = spots[event.chartIndex];

                // Chart drawing area (excluding axes)
                // Right axis: 40px, Bottom axis: 30px
                final chartWidth = constraints.maxWidth - 40;
                final chartHeight = constraints.maxHeight - 30;

                // Calculate X position (same as vertical line)
                final xPercent = spot.x / (widget.chartData.length - 1);
                final xPosition = xPercent * chartWidth;

                // Calculate Y position based on the actual value at this point
                // This matches exactly where the chart line is (center of circle)
                final yRange = (maxY + padding) - (minY - padding);
                final normalizedY = (spot.y - (minY - padding)) / yRange;
                final yPosition =
                    (1 - normalizedY) * chartHeight; // Flip Y axis (0 is top)

                // Circle is 20px (10px radius) - smaller circle with less gap
                final circleCenterY = yPosition;
                final circleBottomY =
                    circleCenterY + 10; // Bottom edge of circle
                final chartBottomY = chartHeight; // Bottom of chart area
                final lineHeight =
                    chartBottomY -
                    circleBottomY; // Height of line from circle bottom to chart bottom

                return Stack(
                  children: [
                    // Custom vertical dashed line from bottom of chart to bottom of circle
                    if (lineHeight > 0)
                      Positioned(
                        left:
                            xPosition -
                            0.75, // Center the 1.5px line (0.75px on each side)
                        top: circleBottomY,
                        child: CustomPaint(
                          size: Size(1.5, lineHeight),
                          painter: _DashedLinePainter(
                            color: AppColors.warning,
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),
                    // Tappable news marker (circle and icon) - larger tap area for better UX
                    Positioned(
                      left: xPosition - 15, // Larger tap area (30px)
                      top: yPosition - 15,
                      child: GestureDetector(
                        onTap: () {
                          widget.onNewsEventTap?.call(event);
                        },
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: Icon(
                              TablerIcons.world, // Globe icon
                              size: 14, // Smaller icon to reduce gap
                              color: AppColors.warning, // Yellow icon
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
      ],
    );
  }
}

/// Custom painter for dashed vertical line
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw dashed line from top (0) to bottom (size.height)
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height);

    // Create dashed effect
    final dashPath = _dashPath(path, dashArray: [5, 5]);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path path, {required List<double> dashArray}) {
    final dashPath = Path();
    final dashArrayLength = dashArray.length;
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      var dashIndex = 0;

      while (distance < metric.length) {
        final isDash = dashIndex % 2 == 0;
        final dashLength = dashArray[dashIndex % dashArrayLength];

        if (isDash) {
          dashPath.addPath(
            metric.extractPath(distance, distance + dashLength),
            Offset.zero,
          );
        }

        distance += dashLength;
        dashIndex++;
      }
    }

    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
