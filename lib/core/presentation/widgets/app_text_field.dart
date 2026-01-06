import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Reusable text field widget with label and optional password visibility toggle
///
/// This is a generic text field that can be used across the app.
/// It matches the Figma design with dark surface background.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    required this.placeholder,
    super.key,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.suffixIcon,
    this.onSuffixIconTap,
  });

  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.obscureText;
    final showObscureToggle = isPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(widget.label, style: AppTextStyles.textFieldLabel()),
        const SizedBox(height: AppSpacing.fieldLabelGap),
        // Input field - wrapped with GestureDetector for better UX
        GestureDetector(
          onTap: () {
            // Request focus when clicking anywhere in the container
            _focusNode.requestFocus();
          },
          child: Container(
            height: AppSpacing.fieldHeight,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    obscureText: isPassword && _obscured,
                    style: AppTextStyles.textFieldInput(),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: AppTextStyles.textFieldInput(),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                    cursorColor: AppColors.primary,
                    onChanged: widget.onChanged,
                  ),
                ),
                if (showObscureToggle)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscured = !_obscured;
                      });
                      widget.onSuffixIconTap?.call();
                    },
                    child:
                        widget.suffixIcon ??
                        (_obscured
                            ? SvgPicture.asset(
                                'assets/icons/eye_closed.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColors.textLabel,
                                  BlendMode.srcIn,
                                ),
                              )
                            : Icon(
                                TablerIcons.eye,
                                size: 16,
                                color: AppColors.textLabel,
                              )),
                  )
                else if (widget.suffixIcon != null)
                  GestureDetector(
                    onTap: widget.onSuffixIconTap,
                    child: widget.suffixIcon,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
