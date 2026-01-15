import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Dedicated chart widget for Stocks Overview screen
/// Matches Figma design exactly with specific styling and layout
class StocksChartWidget extends StatelessWidget {
  final List<double> chartData;

  const StocksChartWidget({
    super.key,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    // Convert data to FlSpot format
    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    // Y-axis values from Figma: 6,830, 6,820, 6,810, 6,800
    // Set fixed range to match Figma exactly
    const minY = 6800.0;
    const maxY = 6830.0;
    final yAxisValues = [6830, 6820, 6810, 6800];

    return Container(
      height: 164.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart area (takes remaining space, leaving room for Y-axis)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 7, left: 3),
              child: Stack(
                children: [
                  LineChart(
                    LineChartData(
                      gridData: const FlGridData(
                        show: false, // Remove grid lines as per Figma
                      ),
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
                        // Bottom X-axis labels - Figma shows: 21, 23, 25, 26, 30
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: (chartData.length / 4).ceilToDouble(),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= chartData.length) {
                                return const SizedBox.shrink();
                              }
                              // Show dates: 21, 23, 25, 26, 30
                              final dates = [21, 23, 25, 26, 30];
                              final dateIndex = (index / (chartData.length / dates.length)).floor();
                              if (dateIndex < dates.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    dates[dateIndex].toString(),
                                    style: AppTextStyles.labelSmall(
                                      color: AppColors.textLabel,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: minY,
                      maxY: maxY,
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
                  // Dashed horizontal line with blue circle at right end
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Get the last data point (end of chart line)
                      final lastSpot = spots.isNotEmpty ? spots.last : null;
                      if (lastSpot == null) {
                        return const SizedBox.shrink();
                      }
                      
                      // Calculate Y position based on the last data point's value
                      final chartHeight = constraints.maxHeight - 30; // Minus bottom axis
                      final yRange = maxY - minY;
                      final normalizedY = (lastSpot.y - minY) / yRange;
                      final yPosition = (1 - normalizedY) * chartHeight; // Flip Y axis
                      
                      final chartWidth = constraints.maxWidth;
                      const circleRadius = 4.0; // Blue circle radius
                      
                      return Stack(
                        children: [
                          // Dashed horizontal line - extend full width
                          Positioned(
                            left: 0,
                            top: yPosition,
                            child: CustomPaint(
                              size: Size(chartWidth, 1),
                              painter: _DashedLinePainter(
                                color: AppColors.textLabel,
                                strokeWidth: 0.5,
                              ),
                            ),
                          ),
                          // Blue circle at right end, following the chart line
                          Positioned(
                            right: 0,
                            top: yPosition - circleRadius,
                            child: Container(
                              width: circleRadius * 2,
                              height: circleRadius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
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
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textLabel,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dashed horizontal line
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw dashed line from left to right
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    // Create dashed effect - longer dashes for better visibility
    final dashPath = _dashPath(path, dashArray: const [8, 4]);
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


