import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/profile/presentation/views/account_center_screen.dart';
import 'package:pulsetrade_app/features/profile/presentation/widgets/trading_mode_modal.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routePath = '/profile';
  static const String routeName = 'profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRealMode = true; // true = Real, false = Demo
  TradingMode _tradingMode = TradingMode.lite;

  @override
  Widget build(BuildContext context) {
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
          strings.profile,
          style: AppTextStyles.headlineLarge(
            color: AppColors.textPrimary,
          ).copyWith(fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Veronica John Doe',
                        style: AppTextStyles.labelLarge(
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: 16, height: 22 / 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID-MRK-920900',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textLabel,
                        ).copyWith(height: 18 / 12),
                      ),
                      const SizedBox(height: 4),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Real/Demo Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRealMode = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _isRealMode
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            strings.real,
                            style: _isRealMode
                                ? AppTextStyles.labelLarge(
                                    color: AppColors.textPrimary,
                                  )
                                : AppTextStyles.bodyLarge(
                                    color: AppColors.textLabel,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRealMode = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: !_isRealMode
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            strings.demo,
                            style: !_isRealMode
                                ? AppTextStyles.labelLarge(
                                    color: AppColors.textPrimary,
                                  )
                                : AppTextStyles.bodyLarge(
                                    color: AppColors.textLabel,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // My Info Section
                    Text(
                      strings.myInfo,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.textLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileMenuItem(
                      icon: TablerIcons.user,
                      title: strings.accountCenter,
                      onTap: () {
                        context.push(AccountCenterScreen.routePath);
                      },
                    ),
                    _ProfileMenuItem(
                      iconAsset: 'assets/icons/blocks.svg',
                      title: strings.tradingMode,
                      badge: _tradingMode == TradingMode.lite
                          ? strings.lite
                          : strings.advanced,
                      onTap: () async {
                        final selected = await TradingModeModal.show(
                          context,
                          currentMode: _tradingMode,
                        );
                        if (selected != null) {
                          setState(() {
                            _tradingMode = selected;
                          });
                        }
                      },
                    ),
                    _ProfileMenuItem(
                      icon: TablerIcons.users_group,
                      title: strings.connectedAccount,
                      onTap: () {
                        // TODO: Navigate to Connected Account
                      },
                    ),
                    _ProfileMenuItem(
                      icon: TablerIcons.history,
                      title: strings.history,
                      onTap: () {
                        // TODO: Navigate to History
                      },
                    ),
                    const SizedBox(height: 24),

                    // Other Section
                    Text(
                      strings.other,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.textLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileMenuItem(
                      icon: TablerIcons.bubble_text,
                      title: strings.faqs,
                      onTap: () {
                        // TODO: Navigate to FAQs
                      },
                    ),
                    _ProfileMenuItem(
                      icon: TablerIcons.shield_check,
                      title: strings.privacy,
                      onTap: () {
                        // TODO: Navigate to Privacy
                      },
                    ),
                    _ProfileMenuItem(
                      icon: TablerIcons.bell_ringing,
                      title: strings.notification,
                      onTap: () {
                        // TODO: Navigate to Notification
                      },
                    ),
                    _ProfileMenuItem(
                      icon: TablerIcons.help_hexagon,
                      title: strings.helpAndSupport,
                      onTap: () {
                        // TODO: Navigate to Help & Support
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String? badge;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    this.icon,
    this.iconAsset,
    required this.title,
    this.badge,
    required this.onTap,
  }) : assert(
         icon != null || iconAsset != null,
         'Either icon or iconAsset must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: iconAsset != null
                  ? SvgPicture.asset(
                      iconAsset!,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(icon, size: 24, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge(color: AppColors.textPrimary),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.labelSmall(color: AppColors.textLabel),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              TablerIcons.chevron_right,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
