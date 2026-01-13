import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// A reusable explanation card widget that displays informational text
/// in a styled container. Used for order explanations, help text, etc.
class ExplanationCard extends StatelessWidget {
  /// The text to display in the explanation card
  final String text;

  /// Whether the card should take full width
  final bool fullWidth;

  /// Custom padding for the card
  final EdgeInsets? padding;

  /// Custom text alignment
  final TextAlign textAlign;

  /// Custom text style
  final TextStyle? textStyle;

  const ExplanationCard({
    super.key,
    required this.text,
    this.fullWidth = true,
    this.padding,
    this.textAlign = TextAlign.center,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        text,
        style: textStyle ??
            AppTextStyles.bodyMedium(color: AppColors.textLabel),
        textAlign: textAlign,
      ),
    );
  }
}

