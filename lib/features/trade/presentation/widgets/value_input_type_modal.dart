import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

enum ValueInputType { value, numberOfShares }

class ValueInputTypeModal extends StatefulWidget {
  final ValueInputType currentType;

  const ValueInputTypeModal({super.key, required this.currentType});

  @override
  State<ValueInputTypeModal> createState() => _ValueInputTypeModalState();

  static Future<ValueInputType?> show(
    BuildContext context, {
    required ValueInputType currentType,
  }) {
    return showDialog<ValueInputType>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => ValueInputTypeModal(currentType: currentType),
    );
  }
}

class _ValueInputTypeModalState extends State<ValueInputTypeModal> {
  late ValueInputType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InputTypeOption(
              label: l10n.value,
              isSelected: _selectedType == ValueInputType.value,
              onTap: () {
                setState(() {
                  _selectedType = ValueInputType.value;
                });
                Navigator.of(context).pop(_selectedType);
              },
            ),
            _InputTypeOption(
              label: l10n.numberOfShares,
              isSelected: _selectedType == ValueInputType.numberOfShares,
              onTap: () {
                setState(() {
                  _selectedType = ValueInputType.numberOfShares;
                });
                Navigator.of(context).pop(_selectedType);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InputTypeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InputTypeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.labelMedium(color: AppColors.textPrimary)
              : AppTextStyles.bodyMedium(color: AppColors.textPrimary),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

