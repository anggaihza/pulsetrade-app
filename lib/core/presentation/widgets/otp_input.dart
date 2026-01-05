import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Clean, simple OTP input widget
///
/// Behavior:
/// - Type digit: Fill current box, move to next
/// - Backspace on filled box: Clear it, stay in box
/// - Backspace on empty box: Move to previous box
/// - Click box: Focus that box
/// - Paste: Fill all boxes from start
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

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
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

  String get _code => _controllers.map((c) => c.text).join();

  void _notifyChange() {
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  void _handleChange(int index, String value) {
    // Handle paste
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    // Handle single digit
    if (value.length == 1) {
      // Move to next box
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
      _notifyChange();
    }
  }

  void _handlePaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    for (int i = 0; i < widget.length && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }

    // Focus last filled box or last box
    final focusIndex = (digits.length - 1).clamp(0, widget.length - 1);
    _focusNodes[focusIndex].requestFocus();

    _notifyChange();
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < widget.length - 1 ? 10 : 0),
            child: _buildBox(index),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(int index) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Center(
        child: Focus(
          onKey: (node, event) {
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              _handleBackspace(index);
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: AppTextStyles.labelMedium(
              color: AppColors.textPrimary,
            ).copyWith(fontSize: 16, height: 1.0),
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
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) => _handleChange(index, value),
          ),
        ),
      ),
    );
  }
}
