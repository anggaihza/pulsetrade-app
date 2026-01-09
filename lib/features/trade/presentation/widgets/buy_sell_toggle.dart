import 'package:flutter/material.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Reusable Buy/Sell toggle widget
///
/// Displays a segmented control for selecting Buy or Sell order type.
class BuySellToggle extends StatelessWidget {
  const BuySellToggle({super.key, required this.isBuy, required this.onToggle});

  final bool isBuy; // true = Buy, false = Sell
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          // Buy button
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 40,
                decoration: BoxDecoration(
                  color: isBuy ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    l10n.buy,
                    style: isBuy
                        ? AppTextStyles.labelLarge(
                            color: AppColors.background,
                          ) // Bold for active
                        : AppTextStyles.bodyLarge(
                            color: AppColors.textLabel,
                          ), // Regular for inactive
                  ),
                ),
              ),
            ),
          ),
          // Sell button
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 40,
                decoration: BoxDecoration(
                  color: !isBuy ? AppColors.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    l10n.sell,
                    style: !isBuy
                        ? AppTextStyles.labelLarge(
                            color: AppColors.background,
                          ) // Bold for active
                        : AppTextStyles.bodyLarge(
                            color: AppColors.textLabel,
                          ), // Regular for inactive
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
