// lib/features/wallet/presentation/widgets/wallet_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/wallet/presentation/providers/wallet_providers.dart';

class WalletTabBar extends StatelessWidget {
  const WalletTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final WalletTab selected;
  final ValueChanged<WalletTab> onChanged;

  static const _anim = Duration(milliseconds: 220);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final half = constraints.maxWidth / 2;

          return Stack(
            children: [
              // Grey base line
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(height: 2, color: AppColors.surface),
              ),

              // Tabs
              Row(
                children: [
                  Expanded(
                    child: _TabItem(
                      label: 'Broker',
                      isActive: selected == WalletTab.broker,
                      onTap: () => onChanged(WalletTab.broker),
                    ),
                  ),
                  Expanded(
                    child: _TabItem(
                      label: 'Cash',
                      isActive: selected == WalletTab.cash,
                      onTap: () => onChanged(WalletTab.cash),
                    ),
                  ),
                ],
              ),

              // ✅ Smooth sliding indicator
              AnimatedPositioned(
                duration: _anim,
                curve: _curve,
                left: selected == WalletTab.broker ? 0 : half,
                bottom: 0,
                child: Container(
                  width: half,
                  height: 2,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const _anim = Duration(milliseconds: 220);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textLabel;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: _anim,
          curve: _curve,
          style: AppTextStyles.titleSmall(color: color).copyWith(
            fontSize: 15, // ✅ bigger text (adjust if needed: 14–16)
            fontWeight: FontWeight.w600, // feels like reference tab label
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
