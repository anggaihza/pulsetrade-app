import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BucketDonutChart extends StatelessWidget {
  final double size;
  final Color avatarColor;
  final String? imageAsset;

  const BucketDonutChart({
    super.key,
    required this.size,
    required this.avatarColor,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    const avatarSize = 48.0;
    final avatarLeft = (size - avatarSize) / 2;
    final avatarTop = (size - avatarSize) / 2;

    final outerRadius = size / 2;
    final ringThickness = outerRadius * 0.2;
    final centerSpaceRadius = outerRadius - ringThickness;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: _createSections(outerRadius, ringThickness),
              sectionsSpace: 0,
              centerSpaceRadius: centerSpaceRadius,
              startDegreeOffset: -90,
            ),
          ),
          Positioned(
            left: avatarLeft,
            top: avatarTop,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset!,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          size: avatarSize * 0.6,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createSections(
    double outerRadius,
    double thickness,
  ) {
    const colors = [
      Color(0xFF8B5CF6),
      Color(0xFFFF6B35),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
    ];

    return List.generate(
      4,
      (index) => PieChartSectionData(
        value: 25,
        color: colors[index],
        radius: thickness,
        showTitle: false,
        borderSide: BorderSide.none,
      ),
    );
  }
}
