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
            isCurved: false, // Sharp line like stocks feature
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
                  AppColors.primary.withValues(
                    alpha: 0.6,
                  ), // Increased from 0.3 for better visibility
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

    // Calculate Y-axis values for display
    final yAxisInterval = (maxY - minY) / 5;
    final yAxisValues = List.generate(6, (i) {
      return (minY - padding + (yAxisInterval * i)).round();
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart area (takes remaining space, leaving room for Y-axis)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              final chartHeight =
                  constraints.maxHeight - 30; // Minus bottom axis

              return Stack(
                children: [
                  // Draw grid lines behind the chart
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7, left: 3),
                      child: CustomPaint(
                        painter: _ChartGridPainter(
                          horizontalInterval: (maxY - minY) / 5,
                          minY: minY - padding,
                          maxY: maxY + padding,
                          chartWidth:
                              chartWidth - 3, // Account for left padding
                          chartHeight:
                              chartHeight - 7, // Account for top padding
                        ),
                      ),
                    ),
                  ),
                  // Chart on top
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 3),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(
                          show: false,
                        ), // Disable grid - we draw it behind
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
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
                              interval: (widget.chartData.length / 10)
                                  .ceilToDouble(),
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= widget.chartData.length) {
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
                              (
                                FlTouchEvent event,
                                LineTouchResponse? touchResponse,
                              ) {
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
                            getTooltipItems:
                                (List<LineBarSpot> touchedBarSpots) {
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
                              (
                                LineChartBarData barData,
                                List<int> spotIndexes,
                              ) {
                                return spotIndexes.map((spotIndex) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: AppColors.textLabel,
                                      strokeWidth: 1,
                                      dashArray: const [5, 5],
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 6,
                                              color: AppColors.warning,
                                              strokeWidth: 2,
                                              strokeColor:
                                                  AppColors.textPrimary,
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
                            isCurved: false, // Sharp line like stocks feature
                            color: AppColors.primary,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: newsEventDotData,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(
                                    alpha: 0.6,
                                  ), // Increased from 0.3 for better visibility
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
                  ),
                  // Draw dashed border box (top, left, right dashed; bottom solid)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7, left: 3),
                      child: CustomPaint(
                        painter: _ChartBorderPainter(
                          chartWidth: chartWidth - 3,
                          chartHeight: chartHeight - 7,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7, left: 3),
                      child: CustomPaint(
                        painter: _ChartBorderPainter(
                          chartWidth: chartWidth - 3,
                          chartHeight: chartHeight - 7,
                        ),
                      ),
                    ),
                  ),
                  // Draw dashed border box (top, left, right dashed; bottom solid)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7, left: 3),
                      child: CustomPaint(
                        painter: _ChartBorderPainter(
                          chartWidth: chartWidth - 3,
                          chartHeight: chartHeight - 7,
                        ),
                      ),
                    ),
                  ),
                  // Overlay custom vertical dashed lines and icons for news event markers
                  if (widget.newsEvents != null &&
                      widget.newsEvents!.isNotEmpty)
                    ...widget.newsEvents!.map((event) {
                      if (event.chartIndex < 0 ||
                          event.chartIndex >= widget.chartData.length) {
                        return const SizedBox.shrink();
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Get the exact spot from the chart data
                          final spot = spots[event.chartIndex];

                          // Chart drawing area (excluding axes and padding)
                          // Account for padding: top: 7, left: 3
                          final chartWidth =
                              constraints.maxWidth -
                              3; // Account for left padding
                          final chartHeight =
                              constraints.maxHeight -
                              30 -
                              7; // Account for bottom axis and top padding

                          // Calculate X position (same as vertical line)
                          // Add left padding offset
                          final xPercent =
                              spot.x / (widget.chartData.length - 1);
                          final xPosition =
                              3 + (xPercent * chartWidth); // Add left padding

                          // Calculate Y position based on the actual value at this point
                          // This matches exactly where the chart line is (center of circle)
                          // Add top padding offset
                          final yRange = (maxY + padding) - (minY - padding);
                          final normalizedY =
                              (spot.y - (minY - padding)) / yRange;
                          final yPosition =
                              7 +
                              (1 - normalizedY) *
                                  chartHeight; // Add top padding, flip Y axis

                          // Circle is 17px diameter (8.5px radius) to match FlDotCirclePainter
                          final circleRadius = 8.5;
                          final circleCenterY = yPosition;
                          final circleBottomY =
                              circleCenterY +
                              circleRadius; // Bottom edge of circle
                          final chartBottomY =
                              constraints.maxHeight -
                              30; // Bottom of chart area (with padding)
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
                              // Tappable news marker (circle and icon) - centered
                              Positioned(
                                left:
                                    xPosition -
                                    circleRadius, // Center the circle
                                top:
                                    yPosition -
                                    circleRadius, // Center the circle
                                child: GestureDetector(
                                  onTap: () {
                                    widget.onNewsEventTap?.call(event);
                                  },
                                  child: SizedBox(
                                    width: circleRadius * 2,
                                    height: circleRadius * 2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Draw circle border manually to match fl_chart's circle
                                        CustomPaint(
                                          size: Size(
                                            circleRadius * 2,
                                            circleRadius * 2,
                                          ),
                                          painter: _CircleBorderPainter(
                                            radius: circleRadius,
                                            strokeWidth: 2,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                        // Globe icon centered
                                        Icon(
                                          TablerIcons.world,
                                          size: 14,
                                          color: AppColors.warning,
                                        ),
                                      ],
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
            },
          ),
        ),
        // Y-axis labels on the right - extends to the right edge
        SizedBox(
          width: 40,
          child: Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: yAxisValues.map((value) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toString(),
                    style: AppTextStyles.labelSmall(color: AppColors.textLabel),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
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

/// Custom painter for chart grid lines (drawn behind the chart)
class _ChartGridPainter extends CustomPainter {
  final double horizontalInterval;
  final double minY;
  final double maxY;
  final double chartWidth;
  final double chartHeight;

  _ChartGridPainter({
    required this.horizontalInterval,
    required this.minY,
    required this.maxY,
    required this.chartWidth,
    required this.chartHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surface
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal dashed lines
    final yRange = maxY - minY;
    var currentY = minY;
    while (currentY <= maxY) {
      final normalizedY = (currentY - minY) / yRange;
      final yPosition = (1 - normalizedY) * chartHeight; // Flip Y axis

      final path = Path();
      path.moveTo(0, yPosition);
      path.lineTo(chartWidth, yPosition);

      final dashPath = _dashPath(path, dashArray: const [5, 5]);
      canvas.drawPath(dashPath, paint);

      currentY += horizontalInterval;
    }
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

/// Custom painter for chart border box
/// Top, left, and right sides are dashed; bottom is solid
class _ChartBorderPainter extends CustomPainter {
  final double chartWidth;
  final double chartHeight;

  _ChartBorderPainter({required this.chartWidth, required this.chartHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surface
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw top dashed line
    final topPath = Path();
    topPath.moveTo(0, 0);
    topPath.lineTo(chartWidth, 0);
    final topDashPath = _dashPath(topPath, dashArray: const [5, 5]);
    canvas.drawPath(topDashPath, paint);

    // Draw left dashed line
    final leftPath = Path();
    leftPath.moveTo(0, 0);
    leftPath.lineTo(0, chartHeight);
    final leftDashPath = _dashPath(leftPath, dashArray: const [5, 5]);
    canvas.drawPath(leftDashPath, paint);

    // Draw right dashed line
    final rightPath = Path();
    rightPath.moveTo(chartWidth, 0);
    rightPath.lineTo(chartWidth, chartHeight);
    final rightDashPath = _dashPath(rightPath, dashArray: const [5, 5]);
    canvas.drawPath(rightDashPath, paint);

    // Draw bottom solid line
    final bottomPath = Path();
    bottomPath.moveTo(0, chartHeight);
    bottomPath.lineTo(chartWidth, chartHeight);
    canvas.drawPath(bottomPath, paint);
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

/// Custom painter for circle border (for news event markers)
class _CircleBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Color color;

  _CircleBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
