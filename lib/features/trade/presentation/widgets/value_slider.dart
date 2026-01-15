import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';

/// Reusable value display widget for trade orders
///
/// Displays trade value with:
/// - Value label with info icon (dynamic: "Value" or "Number of Shares")
/// - Large editable value display with currency or shares count (directly editable)
class ValueSlider extends StatefulWidget {
  const ValueSlider({
    super.key,
    required this.value,
    required this.maxValue,
    required this.numberOfShares,
    required this.inputType,
    required this.stockPrice,
    required this.onInputTypeChanged,
    required this.onValueChanged,
  });

  final double value;
  final double maxValue;
  final int numberOfShares;
  final ValueInputType inputType;
  final double stockPrice;
  final ValueChanged<ValueInputType> onInputTypeChanged;
  final ValueChanged<double> onValueChanged;

  @override
  State<ValueSlider> createState() => _ValueSliderState();
}

class _ValueSliderState extends State<ValueSlider> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _updateControllerValue();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ValueSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.inputType != widget.inputType) {
      final expectedText = widget.inputType == ValueInputType.value
          ? widget.value.toInt().toString()
          : widget.numberOfShares.toString();

      if (_focusNode.hasFocus && _controller.text != expectedText) {
        _isEditing = false;
        _focusNode.unfocus();
      } else if (!_focusNode.hasFocus) {
        _updateControllerValue();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateControllerValue() {
    final String displayValue = widget.inputType == ValueInputType.value
        ? widget.value.toInt().toString()
        : widget.numberOfShares.toString();

    if (!_isEditing) {
      _controller.text = displayValue;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _handleValueChange();
      setState(() {
        _isEditing = false;
      });
      _updateControllerValue();
    } else if (!_focusNode.hasFocus) {
      _updateControllerValue();
    }
  }

  void _handleValueChange() {
    final inputText = _controller.text
        .trim()
        .replaceAll(',', '')
        .replaceAll('\$', '');
    if (inputText.isEmpty) {
      _updateControllerValue();
      return;
    }

    final inputValue = double.tryParse(inputText);
    if (inputValue == null || inputValue < 0) {
      return;
    }

    double newValue;
    if (widget.inputType == ValueInputType.value) {
      newValue = inputValue.clamp(0.0, widget.maxValue);
    } else {
      newValue = (inputValue * widget.stockPrice).clamp(0.0, widget.maxValue);
    }

    widget.onValueChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: BoxDecoration(
          border: const Border(
            bottom: BorderSide(color: AppColors.primary, width: 2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    widget.inputType == ValueInputType.value
                        ? l10n.value
                        : l10n.numberOfShares,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () async {
                      final selectedType = await ValueInputTypeModal.show(
                        context,
                        currentType: widget.inputType,
                      );
                      if (selectedType != null) {
                        widget.onInputTypeChanged(selectedType);
                      }
                    },
                    child: const Icon(
                      TablerIcons.circle_caret_down,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              widget.inputType == ValueInputType.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$',
                          style: AppTextStyles.headlineLarge(
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: 32),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: AppTextStyles.headlineLarge(
                              color: AppColors.textPrimary,
                            ).copyWith(fontSize: 32),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            onTap: () {
                              setState(() {
                                _isEditing = true;
                                final rawValue = widget.value
                                    .toInt()
                                    .toString();
                                _controller.text = rawValue;
                                _controller
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: _controller.text.length),
                                );
                              });
                            },
                            onChanged: (text) {
                              final cleanedText = text.replaceAll(
                                RegExp(r'[^\d]'),
                                '',
                              );
                              if (cleanedText != text) {
                                _controller.value = TextEditingValue(
                                  text: cleanedText,
                                  selection: TextSelection.collapsed(
                                    offset: cleanedText.length,
                                  ),
                                );
                              }
                              if (cleanedText.isNotEmpty) {
                                setState(() {
                                  _isEditing = true;
                                });
                                _handleValueChange();
                              }
                            },
                            onSubmitted: (_) {
                              _focusNode.unfocus();
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'USD',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineLarge(
                              color: AppColors.textPrimary,
                            ).copyWith(fontSize: 32),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            onTap: () {
                              setState(() {
                                _isEditing = true;
                                final rawValue = widget.numberOfShares
                                    .toString();
                                _controller.text = rawValue;
                                _controller
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: _controller.text.length),
                                );
                              });
                            },
                            onChanged: (text) {
                              final cleanedText = text.replaceAll(
                                RegExp(r'[^\d]'),
                                '',
                              );
                              if (cleanedText != text) {
                                _controller.value = TextEditingValue(
                                  text: cleanedText,
                                  selection: TextSelection.collapsed(
                                    offset: cleanedText.length,
                                  ),
                                );
                              }
                              if (cleanedText.isNotEmpty) {
                                setState(() {
                                  _isEditing = true;
                                });
                                _handleValueChange();
                              }
                            },
                            onSubmitted: (_) {
                              _focusNode.unfocus();
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            l10n.shares,
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
