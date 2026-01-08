import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';

/// Typography system based on Figma design tokens
///
/// Single source of truth for all text styles in the app.
/// Usage: Text('Hello', style: AppTextStyles.bodyLarge())
class AppTextStyles {
  AppTextStyles._();

  // Display Styles
  // display-small: Font(family: "Montserrat", style: Bold, size: 40)
  static TextStyle displaySmall({Color? color}) => GoogleFonts.montserrat(
    fontSize: 40,
    fontWeight: FontWeight.w700, // Bold
    height: 1.0,
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // Headline Styles
  // headline-large: Font(family: "Montserrat", style: Bold, size: 24)
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    height: 1.0,
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // Title Styles
  // title-small: Font(family: "Montserrat", style: Bold, size: 16, lineHeight: 22)
  static TextStyle titleSmall({Color? color}) => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    height: 22 / 16, // lineHeight: 22
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // Body Styles
  // body-large: Font(family: "Montserrat", style: Regular, size: 14)
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.0,
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // body-medium: Font(family: "Montserrat", style: Regular, size: 12)
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    height: 1.2,
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // body-small: Font(family: "Montserrat", style: Regular, size: 10)
  static TextStyle bodySmall({Color? color}) => GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w400, // Regular
    height: 1.0,
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // Label Styles
  // label-large: Font(family: "Montserrat", style: Bold, size: 14)
  static TextStyle labelLarge({Color? color}) => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    height: 1.0,
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // label-medium: Font(family: "Montserrat", style: SemiBold, size: 12)
  static TextStyle labelMedium({Color? color}) => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.0,
    letterSpacing: 0,
    color: color ?? AppColors.textLabel,
  );

  // label-small: Font(family: "Montserrat", style: SemiBold, size: 10)
  static TextStyle labelSmall({Color? color}) => GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.0,
    letterSpacing: 0,
    color: color ?? AppColors.textPrimary,
  );

  // Special Purpose Styles
  /// Button text style (label-large with black color for primary buttons)
  static TextStyle buttonPrimary({Color? color}) =>
      labelLarge(color: color ?? AppColors.onPrimary);

  /// Button text style for outlined buttons
  static TextStyle buttonOutlined({Color? color}) =>
      labelLarge(color: color ?? AppColors.textPrimary);

  /// Text field input style
  static TextStyle textFieldInput({Color? color}) =>
      labelMedium(color: color ?? AppColors.textLabel);

  /// Text field label style
  static TextStyle textFieldLabel({Color? color}) =>
      labelMedium(color: color ?? AppColors.textLabel);

  /// Link/underlined text style
  static TextStyle link({Color? color}) =>
      labelLarge(color: color ?? AppColors.textTertiary).copyWith(
        decoration: TextDecoration.underline,
        decorationColor: color ?? AppColors.textTertiary,
      );
}

/// Typography configuration for Flutter's theme system
///
/// This creates a TextTheme for MaterialApp.
/// Material widgets will use these styles via Theme.of(context).textTheme
class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      displaySmall: AppTextStyles.displaySmall(),
      bodyLarge: AppTextStyles.bodyLarge(),
      bodyMedium: AppTextStyles.bodyMedium(),
      labelLarge: AppTextStyles.labelLarge(),
      labelMedium: AppTextStyles.labelMedium(),

      // Legacy styles for backward compatibility
      headlineMedium: AppTextStyles.displaySmall().copyWith(
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      titleMedium: AppTextStyles.labelMedium().copyWith(
        fontSize: 16,
        letterSpacing: -0.25,
      ),
    );
  }
}
