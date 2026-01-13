import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';

/// A reusable slider widget with custom styling
/// Features:
/// - Full-width track
/// - Custom blue-bordered black-filled thumb
/// - Thin track (0.5px height)
class AppSlider extends StatelessWidget {
  /// Current value of the slider
  final double value;

  /// Minimum value
  final double min;

  /// Maximum value
  final double max;

  /// Callback when the value changes
  final ValueChanged<double>? onChanged;

  /// Track height (default: 0.5)
  final double trackHeight;

  /// Thumb radius (default: 8.0)
  final double thumbRadius;

  /// Active track color (default: AppColors.primary)
  final Color? activeTrackColor;

  /// Inactive track color (default: AppColors.textPrimary)
  final Color? inactiveTrackColor;

  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.trackHeight = 0.5,
    this.thumbRadius = 8.0,
    this.activeTrackColor,
    this.inactiveTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: trackHeight,
          activeTrackColor: activeTrackColor ?? AppColors.primary,
          inactiveTrackColor: inactiveTrackColor ?? AppColors.textPrimary,
          thumbColor: Colors.transparent,
          overlayColor: Colors.transparent,
          trackShape: _FullWidthSliderTrackShape(),
          thumbShape: _CustomSliderThumb(enabledThumbRadius: thumbRadius),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Custom track shape that extends to full width without padding
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
    final trackLeft = thumbRadius; // Start after thumb radius
    final trackWidth =
        parentBox.size.width - (2 * thumbRadius); // Full width minus thumb radius on both sides
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
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
    final visualTrackLeft = 0.0; // Visual track starts at the very left edge
    final visualTrackWidth = parentBox.size.width;

    // Draw inactive track (full visual width)
    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? AppColors.textLabel
      ..style = PaintingStyle.fill;

    context.canvas.drawRect(
      Rect.fromLTWH(visualTrackLeft, trackTop, visualTrackWidth, trackHeight),
      inactivePaint,
    );

    // Draw active track - from visual left edge to thumb center
    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? AppColors.primary
      ..style = PaintingStyle.fill;

    final activeWidth =
        (thumbCenter.dx - visualTrackLeft).clamp(0.0, visualTrackWidth);
    if (activeWidth > 0) {
      context.canvas.drawRect(
        Rect.fromLTWH(visualTrackLeft, trackTop, activeWidth, trackHeight),
        activePaint,
      );
    }
  }
}

/// Custom slider thumb that matches the blue circle design
/// The thumb's left edge aligns with the track's left edge when value is at minimum
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

    // Draw the filled black circle
    canvas.drawCircle(
      center,
      enabledThumbRadius,
      Paint()
        ..color = AppColors.background // Black fill
        ..style = PaintingStyle.fill,
    );

    // Draw the blue border
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

