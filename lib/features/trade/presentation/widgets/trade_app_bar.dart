import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Reusable AppBar for trade screens
/// Provides consistent back button and optional title
class TradeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const TradeAppBar({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(
          TablerIcons.arrow_narrow_left,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.titleSmall(color: AppColors.textPrimary),
            )
          : null,
      centerTitle: title != null,
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

