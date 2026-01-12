import 'package:flutter/material.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Order type enum
enum OrderType { marketOrder, limit, stop, stopLimit }

/// Reusable order type tabs widget
///
/// Displays horizontal tabs for selecting order type:
/// - Market order
/// - Limit
/// - Stop
/// - Stop Limit
class OrderTypeTabs extends StatelessWidget {
  const OrderTypeTabs({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final OrderType selectedType;
  final ValueChanged<OrderType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _OrderTypeTab(
              label: l10n.marketOrder,
              isSelected: selectedType == OrderType.marketOrder,
              onTap: () => onTypeSelected(OrderType.marketOrder),
            ),
            _OrderTypeTab(
              label: l10n.limit,
              isSelected: selectedType == OrderType.limit,
              onTap: () => onTypeSelected(OrderType.limit),
            ),
            _OrderTypeTab(
              label: l10n.stop,
              isSelected: selectedType == OrderType.stop,
              onTap: () => onTypeSelected(OrderType.stop),
            ),
            _OrderTypeTab(
              label: l10n.stopLimit,
              isSelected: selectedType == OrderType.stopLimit,
              onTap: () => onTypeSelected(OrderType.stopLimit),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTypeTab extends StatelessWidget {
  const _OrderTypeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.textLabel,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: isSelected
                ? AppTextStyles.labelLarge(color: AppColors.textPrimary)
                : AppTextStyles.bodyLarge(color: AppColors.textLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
