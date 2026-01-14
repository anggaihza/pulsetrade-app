// lib/features/wallet/presentation/views/deposit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/wallet/presentation/providers/deposit_method_provider.dart';

class DepositScreen extends ConsumerWidget {
  const DepositScreen({super.key});

  static const routePath = '/wallet/deposit';
  static const routeName = 'walletDeposit';

  static const Color _selectedBg = Color(0xFF0E2A59);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(depositMethodProvider);

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
          'Deposit',
          style: AppTextStyles.titleMedium(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Top "Add balance to" card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add balance to',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Cash Account',
                              style: AppTextStyles.bodyLarge(
                                color: AppColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/icons/circle-caret-down.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Current Balance: ',
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '\$2,120.55',
                                style:
                                    AppTextStyles.bodySmall(
                                      color: AppColors.textPrimary,
                                    ).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ), // ✅ lebih bold
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Select Deposit Method',
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  // Method cards
                  _DepositMethodCard(
                    title: 'E-Wallet',
                    feeText: '2.5% Fee',
                    icon: TablerIcons.device_tablet_dollar,
                    isSelected: selected == DepositMethod.eWallet,
                    onTap: () => ref
                        .read(depositMethodProvider.notifier)
                        .setMethod(DepositMethod.eWallet),
                  ),

                  const SizedBox(height: 16),

                  _DepositMethodCard(
                    title: 'Bank Transfer',
                    feeText: '10,000 IDR Fee',
                    icon: TablerIcons.world_share,
                    isSelected: selected == DepositMethod.bankTransfer,
                    onTap: () => ref
                        .read(depositMethodProvider.notifier)
                        .setMethod(DepositMethod.bankTransfer),
                  ),

                  const SizedBox(height: 16),

                  _DepositMethodCard(
                    title: 'Virtual Account',
                    feeText: '1.5% Fee',
                    icon: TablerIcons.number,
                    isSelected: selected == DepositMethod.virtualAccount,
                    onTap: () => ref
                        .read(depositMethodProvider.notifier)
                        .setMethod(DepositMethod.virtualAccount),
                  ),

                  const Spacer(),
                  const SizedBox(height: 92), // space for bottom button
                ],
              ),
            ),

            // Bottom fixed CTA
            Positioned(
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              bottom: 20,
              child: SizedBox(
                height: 54,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // TODO: next action
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTextStyles.bodyLarge(
                        color: AppColors.onPrimary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositMethodCard extends StatelessWidget {
  const _DepositMethodCard({
    required this.title,
    required this.feeText,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String feeText;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _selectedBg = Color(0xFF0B2C5C);

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? _selectedBg : AppColors.surface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Container(
              margin: const EdgeInsets.only(left: 28),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                feeText,
                style: AppTextStyles.bodySmall(
                  color: AppColors.black,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
