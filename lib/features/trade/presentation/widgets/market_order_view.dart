import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_slider.dart';
import 'package:pulsetrade_app/core/presentation/widgets/explanation_card.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_slider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/shares_balance_display.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';

/// Reusable Market Order view widget
///
/// Contains all common Market Order UI components:
/// - ValueSlider
/// - AppSlider
/// - SharesBalanceDisplay
/// - ExplanationCard
class MarketOrderView extends StatelessWidget {
  const MarketOrderView({
    super.key,
    required this.value,
    required this.maxValue,
    required this.numberOfShares,
    required this.valueInputType,
    required this.balance,
    required this.stockPrice,
    required this.onValueChanged,
    required this.onInputTypeChanged,
  });

  final double value;
  final double maxValue;
  final int numberOfShares;
  final ValueInputType valueInputType;
  final double balance;
  final double stockPrice;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<ValueInputType> onInputTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
        ValueSlider(
          value: value,
          maxValue: maxValue,
          numberOfShares: numberOfShares,
          inputType: valueInputType,
          stockPrice: stockPrice,
          onInputTypeChanged: onInputTypeChanged,
          onValueChanged: onValueChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        // Slider for value
        GestureDetector(
          // Unfocus TextField when tapping on slider
          onTapDown: (_) {
            FocusScope.of(context).unfocus();
          },
          child: AppSlider(
            value: value,
            min: 0,
            max: maxValue,
            onChanged: onValueChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Value and Balance
        SharesBalanceDisplay(
          shares: numberOfShares,
          value: value,
          inputType: valueInputType,
          balance: balance,
        ),
        const SizedBox(height: AppSpacing.md),
        // Market order explanation
        ExplanationCard(text: l10n.marketOrderExplanation),
      ],
    );
  }
}
