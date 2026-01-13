import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_slider.dart';
import 'package:pulsetrade_app/core/presentation/widgets/explanation_card.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_slider.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/shares_balance_display.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/price_input_stepper.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/expiration_selector.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/value_input_type_modal.dart';

/// Unified builder for order type views (Limit, Stop, StopLimit)
/// Eliminates code duplication across different order type views
class OrderTypeViewBuilder extends StatelessWidget {
  final OrderType orderType;
  final StockData stockData;
  final double value;
  final double maxValue;
  final double balance;
  final ValueInputType valueInputType;
  final double? limitPrice;
  final double? stopPrice;
  final ExpirationType expirationType;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<ValueInputType> onInputTypeChanged;
  final ValueChanged<double>? onLimitPriceChanged;
  final ValueChanged<double>? onStopPriceChanged;
  final ValueChanged<ExpirationType> onExpirationChanged;

  const OrderTypeViewBuilder({
    super.key,
    required this.orderType,
    required this.stockData,
    required this.value,
    required this.maxValue,
    required this.balance,
    required this.valueInputType,
    this.limitPrice,
    this.stopPrice,
    required this.expirationType,
    required this.onValueChanged,
    required this.onInputTypeChanged,
    this.onLimitPriceChanged,
    this.onStopPriceChanged,
    required this.onExpirationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shares = (value / stockData.price).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value/Shares section
        ValueSlider(
          value: value,
          maxValue: maxValue,
          numberOfShares: shares,
          inputType: valueInputType,
          onInputTypeChanged: onInputTypeChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        // Slider for value
        AppSlider(
          value: value,
          min: 0,
          max: maxValue,
          onChanged: onValueChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        // Value and Balance
        SharesBalanceDisplay(
          shares: shares,
          value: value,
          inputType: valueInputType,
          balance: balance,
        ),
        const SizedBox(height: 16),
        // Order type specific content
        ..._buildOrderTypeSpecificContent(context, l10n),
      ],
    );
  }

  List<Widget> _buildOrderTypeSpecificContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (orderType) {
      case OrderType.limit:
        return _buildLimitContent(context, l10n);
      case OrderType.stop:
        return _buildStopContent(context, l10n);
      case OrderType.stopLimit:
        return _buildStopLimitContent(context, l10n);
      default:
        return [];
    }
  }

  List<Widget> _buildLimitContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      // Limit explanation
      ExplanationCard(
        text: l10n.limitExplanation,
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
      const SizedBox(height: 16),
      // Price input
      if (limitPrice != null && onLimitPriceChanged != null)
        PriceInputStepper(
          label: l10n.price,
          value: limitPrice!,
          onIncrement: () => onLimitPriceChanged!(limitPrice! + 1),
          onDecrement: () => onLimitPriceChanged!(
            (limitPrice! - 1).clamp(0.0, double.infinity),
          ),
        ),
      const SizedBox(height: 16),
      // Expiration
      ExpirationSelector(
        expirationType: expirationType,
        onExpirationChanged: onExpirationChanged,
      ),
    ];
  }

  List<Widget> _buildStopContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      // Explanation
      ExplanationCard(
        text: l10n.limitExplanation,
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
      const SizedBox(height: 16),
      // Stop price input
      if (stopPrice != null && onStopPriceChanged != null)
        PriceInputStepper(
          label: l10n.stop,
          value: stopPrice!,
          onIncrement: () => onStopPriceChanged!(stopPrice! + 1),
          onDecrement: () => onStopPriceChanged!(
            (stopPrice! - 1).clamp(0.0, double.infinity),
          ),
        ),
      const SizedBox(height: 16),
      // Expiration
      ExpirationSelector(
        expirationType: expirationType,
        onExpirationChanged: onExpirationChanged,
      ),
    ];
  }

  List<Widget> _buildStopLimitContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      // First explanation
      Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          l10n.limitExplanation,
          style: AppTextStyles.bodyMedium(color: AppColors.textLabel),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 16),
      // Stop price input
      if (stopPrice != null && onStopPriceChanged != null)
        PriceInputStepper(
          label: l10n.stop,
          value: stopPrice!,
          onIncrement: () => onStopPriceChanged!(stopPrice! + 1),
          onDecrement: () => onStopPriceChanged!(
            (stopPrice! - 1).clamp(0.0, double.infinity),
          ),
        ),
      const SizedBox(height: 16),
      // Second explanation
      const ExplanationCard(
        text:
            'Then, set the maximum price you are willing to pay per share', // TODO: Use l10n.stopLimitExplanation after regenerating localization
        padding: EdgeInsets.all(AppSpacing.sm),
      ),
      const SizedBox(height: 16),
      // Limit price input
      if (limitPrice != null && onLimitPriceChanged != null)
        PriceInputStepper(
          label: l10n.limit,
          value: limitPrice!,
          onIncrement: () => onLimitPriceChanged!(limitPrice! + 1),
          onDecrement: () => onLimitPriceChanged!(
            (limitPrice! - 1).clamp(0.0, double.infinity),
          ),
        ),
      const SizedBox(height: 16),
      // Expiration
      ExpirationSelector(
        expirationType: expirationType,
        onExpirationChanged: onExpirationChanged,
      ),
    ];
  }
}

