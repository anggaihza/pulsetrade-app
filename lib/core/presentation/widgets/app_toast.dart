import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Toast/Snackbar type
enum ToastType {
  success,
  warning,
  error,
}

/// Standardized toast notifications following the app's design system
class AppToast {
  /// Show a success toast
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, ToastType.success, duration);
  }

  /// Show a warning toast
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, ToastType.warning, duration);
  }

  /// Show an error toast
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, ToastType.error, duration);
  }

  /// Show a toast with custom type
  static void _show(
    BuildContext context,
    String message,
    ToastType type,
    Duration duration,
  ) {
    final config = _getToastConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _ToastContent(
          message: message,
          icon: config.icon,
          iconColor: config.iconColor,
        ),
        backgroundColor: config.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
      ),
    );
  }

  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          icon: TablerIcons.circle_check,
          iconColor: const Color(0xFF1BC865), // Green Normal - #1bc865
          backgroundColor: const Color(0xFF094623), // Green Darker - #094623
        );
      case ToastType.warning:
        return _ToastConfig(
          icon: TablerIcons.alert_triangle,
          iconColor: const Color(0xFFFFC107), // Yellow Normal - #ffc107
          backgroundColor: const Color(0xFF594402), // Yellow Darker - #594402
        );
      case ToastType.error:
        return _ToastConfig(
          icon: TablerIcons.circle_x,
          iconColor: const Color(0xFFFF4D4D), // Orange Normal - #ff4d4d
          backgroundColor: const Color(0xFF591B1B), // Orange Darker - #591b1b
        );
    }
  }
}

class _ToastConfig {
  const _ToastConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  final String message;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium(
                color: AppColors.textPrimary,
              ).copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

