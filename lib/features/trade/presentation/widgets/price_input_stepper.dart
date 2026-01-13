import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/formatters.dart';

/// Reusable price input stepper widget with increment/decrement buttons
/// Used for Price, Stop, and Limit inputs in trade screens
class PriceInputStepper extends StatelessWidget {
  final String label;
  final double value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const PriceInputStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              Formatters.formatNumber(value.toInt()),
              style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
            ),
          ],
        ),
        // Stacked buttons in pill-shaped container
        Container(
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Up button (light blue background)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_up,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  onPressed: onIncrement,
                ),
              ),
              // Down button (gray background, extends upward)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    TablerIcons.caret_down,
                    size: 24,
                    color: AppColors.textLabel,
                  ),
                  onPressed: onDecrement,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

