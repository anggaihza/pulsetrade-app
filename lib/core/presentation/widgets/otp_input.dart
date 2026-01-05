import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Reusable OTP input widget with proper UX
///
/// Features:
/// - Auto-advance to next field when typing
/// - Backspace: clears current field, then moves to previous
/// - Paste support: distributes digits across fields
/// - Click any box to focus it
/// - Smooth focus transitions
class OTPInput extends StatefulWidget {
  const OTPInput({
    required this.onCompleted,
    super.key,
    this.onChanged,
    this.length = 6,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _previousValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _previousValues = List.generate(widget.length, (_) => '');
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    // Handle paste (multiple characters)
    if (value.length > 1) {
      _handlePaste(value, index);
      return;
    }

    final previousValue = _previousValues[index];

    // Handle backspace (field became empty)
    if (value.isEmpty && previousValue.isNotEmpty) {
      _previousValues[index] = '';
      // Stay in current field after clearing
      // Next backspace will be handled by Focus onKey to move to previous
      _notifyChange();
      return;
    }

    // Handle single character input
    if (value.length == 1) {
      // Limit to just the last character if somehow more got through
      if (value != previousValue) {
        _controllers[index].text = value[value.length - 1];
        _previousValues[index] = _controllers[index].text;

        // Auto-advance to next field
        if (index < widget.length - 1) {
          _focusNodes[index + 1].requestFocus();
        } else {
          // Last field filled, unfocus to hide keyboard
          _focusNodes[index].unfocus();
        }
      }
    }

    // Notify parent of changes
    _notifyChange();
  }

  void _notifyChange() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);

    // Check if all fields are filled
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < widget.length - 1 ? 10 : 0),
            child: _buildOTPBox(index),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return GestureDetector(
      onTap: () {
        _focusNodes[index].requestFocus();
        // Move cursor to end of text
        _controllers[index].selection = TextSelection.fromPosition(
          TextPosition(offset: _controllers[index].text.length),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        alignment: Alignment.center,
        child: Focus(
          onKey: (node, event) {
            // Handle backspace on empty field to move to previous
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              if (_controllers[index].text.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: AppTextStyles.labelMedium(color: AppColors.textPrimary)
                .copyWith(
                  fontSize: 16,
                  height: 1.0, // Line height 100% as in Figma
                ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
              isDense: true,
              filled: false,
              fillColor: Colors.transparent,
            ),
            cursorColor: AppColors.primary,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              // No length limiter to allow paste detection
            ],
            onChanged: (value) => _onChanged(index, value),
          ),
        ),
      ),
    );
  }

  void _handlePaste(String value, int startIndex) {
    // Extract only digits from pasted text
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) return;

    final digits = digitsOnly.split('');

    // Clear all fields first
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].clear();
      _previousValues[i] = '';
    }

    // Fill fields with pasted digits starting from the beginning
    final maxFill = digits.length.clamp(0, widget.length);
    for (int i = 0; i < maxFill; i++) {
      _controllers[i].text = digits[i];
      _previousValues[i] = digits[i];
    }

    // Focus the next empty field or last filled field
    if (maxFill < widget.length) {
      // Focus next empty field
      _focusNodes[maxFill].requestFocus();
    } else {
      // All filled, focus last field and unfocus
      _focusNodes[widget.length - 1].requestFocus();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNodes[widget.length - 1].unfocus();
        }
      });
    }

    // Notify parent
    _notifyChange();
  }

  /// Clear all OTP fields and focus first box
  void clear() {
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].clear();
      _previousValues[i] = '';
    }
    if (mounted && _focusNodes[0].canRequestFocus) {
      _focusNodes[0].requestFocus();
    }
  }
}
