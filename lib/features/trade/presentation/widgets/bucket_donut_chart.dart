import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Donut chart widget for bucket visualization
/// Shows a donut chart with multiple segments and a center avatar
class BucketDonutChart extends StatelessWidget {
  final double size;
  final Color avatarColor;

  const BucketDonutChart({
    super.key,
    required this.size,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    // Avatar size is 48px, positioned at 26.5px from left and 26px from top
    const avatarSize = 48.0;
    const avatarLeft = 26.5;
    const avatarTop = 26.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Custom painted donut chart
          CustomPaint(size: Size(size, size), painter: _DonutChartPainter()),
          // Center avatar circle - positioned exactly as in Figma
          Positioned(
            left: avatarLeft,
            top: avatarTop,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 24,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for donut chart with 4 segments
class _DonutChartPainter extends CustomPainter {
  // Colors matching Figma design exactly
  static const _colors = [
    Color(0xFF8B5CF6), // Purple (more vibrant)
    Color(0xFFFF6B35), // Orange (more vibrant)
    Color(0xFF3B82F6), // Light Blue (more vibrant)
    Color(0xFFEF4444), // Red (more vibrant)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2; // 50px for 100px size

    // Based on Figma design: very thin ring with visible gap to avatar
    // Avatar is 48px (radius 24px), positioned at 26.5px from left
    // For a thin ring matching Figma exactly, use ~3px thickness
    // Inner radius: 50 - 3 = 47px (creates 3px thick ring)
    // Gap to avatar: 47 - 24 = 23px (visible gap matching Figma)
    // The gap appears larger because avatar is slightly off-center (26.5px vs 26px would be centered)
    final ringThickness = 10.0; // Very thin ring matching Figma
    final innerRadius = outerRadius - ringThickness; // 47px

    // Each segment is 25% (90 degrees)
    const segmentAngle = math.pi * 2 / 4; // 90 degrees in radians
    double startAngle = -math.pi / 2; // Start from top (-90 degrees)

    for (int i = 0; i < 4; i++) {
      // Draw donut segment using Path
      final path = Path();

      // Start from inner arc point
      final innerStartX = center.dx + innerRadius * math.cos(startAngle);
      final innerStartY = center.dy + innerRadius * math.sin(startAngle);
      path.moveTo(innerStartX, innerStartY);

      // Draw inner arc (clockwise)
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        segmentAngle,
        false,
      );

      // Draw line to outer arc
      final outerEndX =
          center.dx + outerRadius * math.cos(startAngle + segmentAngle);
      final outerEndY =
          center.dy + outerRadius * math.sin(startAngle + segmentAngle);
      path.lineTo(outerEndX, outerEndY);

      // Draw outer arc (counter-clockwise back)
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle + segmentAngle,
        -segmentAngle,
        false,
      );

      // Close path
      path.close();

      final segmentPaint = Paint()
        ..color = _colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, segmentPaint);

      startAngle += segmentAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
