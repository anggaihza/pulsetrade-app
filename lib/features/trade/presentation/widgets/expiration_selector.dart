import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/expiration_bottom_sheet.dart';

/// Reusable expiration selector widget
/// Displays current expiration type and opens bottom sheet on tap
class ExpirationSelector extends StatelessWidget {
  final ExpirationType expirationType;
  final ValueChanged<ExpirationType> onExpirationChanged;

  const ExpirationSelector({
    super.key,
    required this.expirationType,
    required this.onExpirationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expirationText = expirationType == ExpirationType.never
        ? l10n.never
        : l10n.endOfDay;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final result = await ExpirationBottomSheet.show(
          context,
          currentType: expirationType,
        );
        if (result != null) {
          onExpirationChanged(result);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  TablerIcons.clock,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.expiration,
                  style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  expirationText,
                  style: AppTextStyles.labelMedium(color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  TablerIcons.chevron_right,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

