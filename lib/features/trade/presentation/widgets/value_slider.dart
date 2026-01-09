import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';

/// Reusable value display widget for trade orders
///
/// Displays trade value with:
/// - Value label with info icon
/// - Large value display with currency
class ValueSlider extends StatelessWidget {
  const ValueSlider({
    super.key,
    required this.value,
    required this.maxValue,
    required this.inputType,
    required this.onInputTypeChanged,
  });

  final double value;
  final double maxValue;
  final ValueInputType inputType;
  final ValueChanged<ValueInputType> onInputTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            // Value label with info icon
            Row(
              children: [
                Text(
                  l10n.value,
                  style: AppTextStyles.labelMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final selectedType = await ValueInputTypeModal.show(
                      context,
                      currentType: inputType,
                    );
                    if (selectedType != null) {
                      onInputTypeChanged(selectedType);
                    }
                  },
                  child: const Icon(
                    TablerIcons.circle_caret_down,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Large value display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatValue(value)}',
                  style: AppTextStyles.headlineLarge(
                    color: AppColors.textPrimary,
                  ).copyWith(fontSize: 32),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'USD',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format value with comma separator
  String _formatValue(double value) {
    final integerValue = value.toInt();
    return integerValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
