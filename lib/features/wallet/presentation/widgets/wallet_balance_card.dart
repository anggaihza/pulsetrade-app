// lib/features/wallet/presentation/widgets/wallet_balance_card.dart
import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.showInterestPill,
    required this.interestText,
    required this.totalBalance,
    required this.currency,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onEyeTap,
    required this.onMenuTap,
  });

  final bool showInterestPill;
  final String interestText;
  final String totalBalance;
  final String currency;

  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onEyeTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final double contentTopPadding = showInterestPill ? 26 : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          /// ✅ Menu icon anchored to top-right (doesn't add height)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onMenuTap,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          /// ✅ Interest pill anchored to top-left (Cash only)
          if (showInterestPill)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  interestText,
                  style: AppTextStyles.labelSmall(color: AppColors.background),
                ),
              ),
            ),

          /// ✅ Main content
          Padding(
            padding: EdgeInsets.only(top: contentTopPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Total Balance
                SizedBox(
                  height: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total Balance',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onEyeTap,
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: Center(
                            child: Icon(
                              TablerIcons.eye_filled,
                              size: 16,
                              color: AppColors.textLabel,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                /// Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(totalBalance, style: AppTextStyles.headlineLarge()),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        currency,
                        style: AppTextStyles.bodySmall(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Buttons
                Row(
                  children: [
                    Expanded(
                      child: _PrimaryButton(label: 'Deposit', onTap: onDeposit),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryButton(
                        label: 'Withdraw',
                        onTap: onWithdraw,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium(
            color: AppColors.onPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium(
            color: AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
