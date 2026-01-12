import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

enum ExpirationType { never, endOfDay }

class ExpirationBottomSheet extends StatefulWidget {
  final ExpirationType currentType;

  const ExpirationBottomSheet({super.key, required this.currentType});

  @override
  State<ExpirationBottomSheet> createState() => _ExpirationBottomSheetState();

  static Future<ExpirationType?> show(
    BuildContext context, {
    required ExpirationType currentType,
  }) {
    return showModalBottomSheet<ExpirationType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ExpirationBottomSheet(currentType: currentType),
        );
      },
    );
  }
}

class _ExpirationBottomSheetState extends State<ExpirationBottomSheet> {
  late ExpirationType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 74,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.textLabel,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _ExpirationOption(
                  label: l10n.never,
                  isSelected: _selectedType == ExpirationType.never,
                  onTap: () {
                    setState(() {
                      _selectedType = ExpirationType.never;
                    });
                    Navigator.of(context).pop(_selectedType);
                  },
                ),
                const SizedBox(height: 8),
                _ExpirationOption(
                  label:
                      'End of Day', // TODO: Use l10n.endOfDay after regenerating localization
                  isSelected: _selectedType == ExpirationType.endOfDay,
                  onTap: () {
                    setState(() {
                      _selectedType = ExpirationType.endOfDay;
                    });
                    Navigator.of(context).pop(_selectedType);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpirationOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpirationOption({
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
              ? AppTextStyles.labelLarge(color: AppColors.textPrimary)
              : AppTextStyles.bodyLarge(color: AppColors.textPrimary),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
