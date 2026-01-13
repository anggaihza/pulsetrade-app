import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Reusable error screen for trade screens
/// Displays an error message with a back button in the AppBar
class TradeErrorScreen extends StatelessWidget {
  final Object error;

  const TradeErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
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
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Error loading stock data: $error',
          style: AppTextStyles.bodyLarge(color: AppColors.error),
        ),
      ),
    );
  }
}

