import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Overlay widget that shows gesture hints on first entry to the home feed.
///
/// Displays:
/// - Swipe arrow icon
/// - "Swipe right for charts" text
/// - "Swipe left to buy" text
///
/// The overlay can be dismissed by tapping anywhere on it.
class GestureHintOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const GestureHintOverlay({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: AppColors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Swipe arrow icon
              SizedBox(
                width: 100,
                height: 100,
                child: SvgPicture.asset(
                  'assets/icons/swipe-arrow.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 25),

              // Hint text
              Text(
                strings.swipeRightForCharts,
                style: AppTextStyles.labelLarge(
                  color: AppColors.whiteNormal,
                ).copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                strings.swipeLeftToBuy,
                style: AppTextStyles.labelLarge(
                  color: AppColors.whiteNormal,
                ).copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

