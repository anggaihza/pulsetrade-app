import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

enum TradingMode {
  lite,
  advanced,
}

class TradingModeModal extends StatefulWidget {
  final TradingMode currentMode;

  const TradingModeModal({
    super.key,
    required this.currentMode,
  });

  @override
  State<TradingModeModal> createState() => _TradingModeModalState();

  static Future<TradingMode?> show(
    BuildContext context, {
    required TradingMode currentMode,
  }) {
    return showDialog<TradingMode>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => TradingModeModal(currentMode: currentMode),
    );
  }
}

class _TradingModeModalState extends State<TradingModeModal> {
  late TradingMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    
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
            // Title
            Text(
              strings.tradingMode,
              style: AppTextStyles.labelSmall(
                color: AppColors.textLabel,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),

            // Options
            _ModeOption(
              label: strings.lite,
              isSelected: _selectedMode == TradingMode.lite,
              onTap: () {
                setState(() {
                  _selectedMode = TradingMode.lite;
                });
                Navigator.of(context).pop(_selectedMode);
              },
            ),
            _ModeOption(
              label: strings.advanced,
              isSelected: _selectedMode == TradingMode.advanced,
              onTap: () {
                setState(() {
                  _selectedMode = TradingMode.advanced;
                });
                Navigator.of(context).pop(_selectedMode);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOption({
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
              ? AppTextStyles.labelMedium(
                  color: AppColors.textPrimary,
                )
              : AppTextStyles.bodyMedium(
                  color: AppColors.textPrimary,
                ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

