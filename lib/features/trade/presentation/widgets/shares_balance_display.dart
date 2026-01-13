import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/formatters.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Reusable shares and balance display widget
/// Shows shares/value and balance information based on input type
class SharesBalanceDisplay extends StatelessWidget {
  final int shares;
  final double value;
  final ValueInputType inputType;
  final double balance;

  const SharesBalanceDisplay({
    super.key,
    required this.shares,
    required this.value,
    required this.inputType,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              inputType == ValueInputType.value
                  ? '${l10n.shares} : '
                  : '${l10n.value} : ',
              style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              inputType == ValueInputType.value
                  ? Formatters.formatNumber(shares)
                  : '\$${Formatters.formatValue(value)}',
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${l10n.balance} : ',
              style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '\$${Formatters.formatNumber(balance.toInt())}',
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }
}

