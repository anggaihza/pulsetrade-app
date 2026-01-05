import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Reusable Google sign-in button
/// 
/// This button can be used anywhere Google authentication is needed.
/// It has a transparent background with border (outlined style).
class GoogleButton extends StatelessWidget {
  const GoogleButton({
    required this.onPressed,
    this.label = 'Continue with Google',
    super.key,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.fieldHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google logo from assets
              SvgPicture.asset(
                'assets/images/google_logo.svg',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 11),
              Text(label, style: AppTextStyles.buttonOutlined()),
            ],
          ),
        ),
      ),
    );
  }
}

