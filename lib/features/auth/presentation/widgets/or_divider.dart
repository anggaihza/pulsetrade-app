import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Divider widget with "or" text in the center, matching Figma design
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(child: Container(height: 0.5, color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(strings.or, style: AppTextStyles.bodyMedium()),
        ),
        Expanded(child: Container(height: 0.5, color: AppColors.border)),
      ],
    );
  }
}
