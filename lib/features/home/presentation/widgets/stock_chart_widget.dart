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
      return _buildMiniChart();
    }
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
            isCurved: false,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.6),
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

    final newsEventDotData =
        widget.newsEvents != null && widget.newsEvents!.isNotEmpty
        ? FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isNewsEvent = widget.newsEvents!.any(
                (event) => event.chartIndex == index,
              );
              if (isNewsEvent) {
                return FlDotCirclePainter(
                  radius: 8.5,
                  color: Colors.transparent,
                  strokeWidth: 2,
                  strokeColor: AppColors.warning,
                );
              }
              return FlDotCirclePainter(radius: 0, color: Colors.transparent);
            },
          )
        : const FlDotData(show: false);

    final yAxisInterval = (maxY - minY) / 5;
    final yAxisValues = List.generate(6, (i) {
      return (minY - padding + (yAxisInterval * i)).round();
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              final chartHeight = constraints.maxHeight - 30;

              return Stack(
                children: [
                  // Grid behind chart - must not steal taps
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7, left: 3),
                        child: CustomPaint(
                          painter: _ChartGridPainter(
                            horizontalInterval: (maxY - minY) / 5,
                            minY: minY - padding,
                            maxY: maxY + padding,
                            chartWidth: chartWidth - 3,
                            chartHeight: chartHeight - 7,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Chart
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 3),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
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

                        // ✅ IMPORTANT: let fl_chart manage touch state (tooltip/indicator)
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchSpotThreshold: 24,
                          touchTooltipData: LineTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipColor: (touchedSpot) => AppColors.warning,
                            getTooltipItems: (touchedBarSpots) {
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
                          getTouchedSpotIndicator: (barData, spotIndexes) {
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
                            isCurved: false,
                            color: AppColors.primary,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: newsEventDotData,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.6),
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

                  // Border overlay - must not steal taps
                  Positioned.fill(
                    child: IgnorePointer(
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
                  ),

                  // News markers overlay (only marker itself is tappable)
                  if (widget.newsEvents != null &&
                      widget.newsEvents!.isNotEmpty)
                    ...widget.newsEvents!.map((event) {
                      if (event.chartIndex < 0 ||
                          event.chartIndex >= widget.chartData.length) {
                        return const SizedBox.shrink();
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final spot = spots[event.chartIndex];

                          final localChartWidth = constraints.maxWidth - 3;
                          final localChartHeight =
                              constraints.maxHeight - 30 - 7;

                          final xPercent =
                              spot.x / (widget.chartData.length - 1);
                          final xPosition = 3 + (xPercent * localChartWidth);

                          final yRange = (maxY + padding) - (minY - padding);
                          final normalizedY =
                              (spot.y - (minY - padding)) / yRange;
                          final yPosition =
                              7 + (1 - normalizedY) * localChartHeight;

                          final circleRadius = 8.5;
                          final circleBottomY = yPosition + circleRadius;
                          final chartBottomY = constraints.maxHeight - 30;
                          final lineHeight = chartBottomY - circleBottomY;

                          return Stack(
                            children: [
                              if (lineHeight > 0)
                                Positioned(
                                  left: xPosition - 0.75,
                                  top: circleBottomY,
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      size: Size(1.5, lineHeight),
                                      painter: _DashedLinePainter(
                                        color: AppColors.warning,
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                left: xPosition - circleRadius,
                                top: yPosition - circleRadius,
                                child: GestureDetector(
                                  onTap: () =>
                                      widget.onNewsEventTap?.call(event),
                                  child: SizedBox(
                                    width: circleRadius * 2,
                                    height: circleRadius * 2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
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

        // Y-axis labels
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

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height);

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

/// Custom painter for chart grid lines
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

    final yRange = maxY - minY;
    var currentY = minY;

    while (currentY <= maxY) {
      final normalizedY = (currentY - minY) / yRange;
      final yPosition = (1 - normalizedY) * chartHeight;

      final path = Path()
        ..moveTo(0, yPosition)
        ..lineTo(chartWidth, yPosition);

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

    // top dashed
    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(chartWidth, 0);
    canvas.drawPath(_dashPath(topPath, dashArray: const [5, 5]), paint);

    // left dashed
    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, chartHeight);
    canvas.drawPath(_dashPath(leftPath, dashArray: const [5, 5]), paint);

    // right dashed
    final rightPath = Path()
      ..moveTo(chartWidth, 0)
      ..lineTo(chartWidth, chartHeight);
    canvas.drawPath(_dashPath(rightPath, dashArray: const [5, 5]), paint);

    // bottom solid
    final bottomPath = Path()
      ..moveTo(0, chartHeight)
      ..lineTo(chartWidth, chartHeight);
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

/// Custom painter for circle border (news marker)
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
