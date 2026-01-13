import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Reusable order footer widget
/// Displays order execution message and review order button
class OrderFooter extends StatelessWidget {
  final String executionTime;
  final VoidCallback onReviewOrder;
  final bool isFloating;

  const OrderFooter({
    super.key,
    required this.executionTime,
    required this.onReviewOrder,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isFloating ? 0 : AppSpacing.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: l10n.orderExecutionMessage,
              style: AppTextStyles.bodySmall(
                color: AppColors.textLabel,
              ).copyWith(fontSize: 10),
              children: [
                TextSpan(
                  text: executionTime,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.primary,
                  ).copyWith(fontSize: 10),
                ),
              ],
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: AppSpacing.md - AppSpacing.xs),
          AppButton(
            label: l10n.reviewOrder,
            onPressed: onReviewOrder,
          ),
        ],
      ),
    );
  }
}

