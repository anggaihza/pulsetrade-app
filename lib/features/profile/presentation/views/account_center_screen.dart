import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/toast_utils.dart';
import 'package:pulsetrade_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:pulsetrade_app/features/auth/presentation/views/login_screen.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class AccountCenterScreen extends ConsumerWidget {
  const AccountCenterScreen({super.key});

  static const String routePath = '/account-center';
  static const String routeName = 'account-center';

  void _copyToClipboard(BuildContext context, String text, String label) {
    final strings = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: text));
    showSuccessToast(context, strings.copiedToClipboard(label));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          strings.accountCenter,
          style: AppTextStyles.titleMedium(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Card
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.textLabel,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name
                          Text(
                            'Veronica John Doe',
                            style: AppTextStyles.labelLarge(
                              color: AppColors.textPrimary,
                            ).copyWith(fontSize: 16, height: 22 / 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Info Rows
                          _InfoRow(
                            label: strings.id,
                            value: 'ID-MRK-920900',
                            onCopy: () => _copyToClipboard(
                              context,
                              'ID-MRK-920900',
                              strings.id,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: strings.email,
                            value: 'tes@example.com',
                            onCopy: () => _copyToClipboard(
                              context,
                              'tes@example.com',
                              strings.email,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: strings.phone,
                            value: '0812-3456-7890',
                            onCopy: () => _copyToClipboard(
                              context,
                              '0812-3456-7890',
                              strings.phone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Verifications Menu Item
                  InkWell(
                    onTap: () {
                      // TODO: Navigate to Verifications
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            TablerIcons.id,
                            size: 24,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              strings.verifications,
                              style: AppTextStyles.bodyLarge(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF094623),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              strings.verified,
                              style: AppTextStyles.labelSmall(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            TablerIcons.chevron_right,
                            size: 24,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Security Menu Item
                  InkWell(
                    onTap: () {
                      // TODO: Navigate to Security
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            TablerIcons.lock_square_rounded_filled,
                            size: 24,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              strings.security,
                              style: AppTextStyles.bodyLarge(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            TablerIcons.chevron_right,
                            size: 24,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Log out button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  showSuccessToast(context, strings.loggingOut);
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(LoginScreen.routePath);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEDED),
                  foregroundColor: const Color(0xFFFF4D4D),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: AppColors.background,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  strings.logOut,
                  style: AppTextStyles.labelLarge(
                    color: const Color(0xFFFF4D4D),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.textLabel),
        ),
        Row(
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCopy,
              child: const Icon(
                TablerIcons.clipboard_text,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
