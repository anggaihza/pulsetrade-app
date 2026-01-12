import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Reusable button widget matching Figma design
/// 
/// Supports primary (filled) and outlined button styles.
/// Can be used across the entire app for consistent button styling.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSpacing.fieldHeight,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : Colors.transparent,
        border: isPrimary
            ? null
            : Border.all(color: AppColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? AppColors.onPrimary : AppColors.textPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: isPrimary
                            ? AppTextStyles.buttonPrimary()
                            : AppTextStyles.buttonOutlined(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
