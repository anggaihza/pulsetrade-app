import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:pulsetrade_app/features/wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:pulsetrade_app/features/wallet/presentation/widgets/wallet_tab_bar.dart';
import 'package:pulsetrade_app/features/wallet/presentation/views/deposit_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const routePath = '/wallet';
  static const routeName = 'wallet';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WalletTab tab = ref.watch(walletTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),

              /// Title
              Text('Wallet', style: AppTextStyles.titleMedium()),

              const SizedBox(height: 18),

              /// Broker / Cash tabs
              WalletTabBar(
                selected: tab,
                onChanged: (WalletTab value) {
                  ref.read(walletTabProvider.notifier).setTab(value);
                },
              ),

              const SizedBox(height: 16),

              /// Balance Card
              WalletBalanceCard(
                showInterestPill: tab == WalletTab.cash,
                interestText: '5.2% IR',
                totalBalance: r'$2,120.55',
                currency: 'USD',
                onDeposit: () {
                  context.go(DepositScreen.routePath);
                },
                onWithdraw: () {},
                onEyeTap: () {},
                onMenuTap: () {},
              ),

              const SizedBox(height: 16),

              /// Divider
              Container(height: 0.5, color: AppColors.whiteActive),

              const SizedBox(height: 28),

              /// Portfolio
              const _InfoRow(label: 'Portfolio', value: r'$1,800.55'),

              const SizedBox(height: 24),

              /// Free Funds
              const _InfoRow(label: 'Free Funds', value: r'$320'),

              /// Keeps content at top like reference
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
        ),
        const Spacer(),
        Text(value, style: AppTextStyles.labelLarge()),
      ],
    );
  }
}
