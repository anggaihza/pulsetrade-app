import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/auth/domain/entities/verification_type.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Bottom sheet to select verification type (Email or Phone)
class VerificationTypeBottomSheet extends StatelessWidget {
  const VerificationTypeBottomSheet({
    required this.contact,
    super.key,
  });

  final String contact;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.textLabel,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Text(
            strings.chooseVerificationMethod,
            style: AppTextStyles.labelLarge().copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          // Subtitle
          Text(
            strings.chooseVerificationSubtitle,
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Email option
          _VerificationOption(
            icon: TablerIcons.mail_filled,
            title: strings.emailVerification,
            subtitle: contact,
            onTap: () {
              Navigator.pop(context, VerificationType.email);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // Phone option
          _VerificationOption(
            icon: TablerIcons.phone,
            title: strings.phoneVerification,
            subtitle: contact,
            onTap: () {
              Navigator.pop(context, VerificationType.phone);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  /// Show the bottom sheet and return selected verification type
  static Future<VerificationType?> show(
    BuildContext context, {
    required String contact,
  }) {
    return showModalBottomSheet<VerificationType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VerificationTypeBottomSheet(contact: contact),
    );
  }
}

/// Individual verification option card
class _VerificationOption extends StatelessWidget {
  const _VerificationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(
                TablerIcons.chevron_right,
                color: AppColors.textLabel,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
