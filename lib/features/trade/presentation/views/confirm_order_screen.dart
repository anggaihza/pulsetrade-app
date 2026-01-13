import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/formatters.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/expiration_type.dart';
import 'package:pulsetrade_app/features/trade/domain/entities/order_type.dart';
import 'package:pulsetrade_app/features/trade/domain/models/order_confirmation_data.dart';

class ConfirmOrderScreen extends StatelessWidget {
  const ConfirmOrderScreen({super.key, required this.orderData});

  static const String routePath = '/confirm-order';
  static const String routeName = 'confirm-order';

  final OrderConfirmationData orderData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top section with logo and ticker
                      Column(
                        children: [
                          // Checkmark icon (white circle with black checkmark)
                          Container(
                            width: 112,
                            height: 112,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                            child: const Icon(
                              TablerIcons.check,
                              size: 56,
                              color: AppColors.background,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Stock ticker and company name
                          Text(
                            orderData.ticker,
                            style: AppTextStyles.titleSmall(
                              color: AppColors.textPrimary,
                            ).copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            orderData.companyName,
                            style: AppTextStyles.bodyLarge(
                              color: AppColors.textLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Order details
                      _buildOrderDetails(l10n),
                    ],
                  ),
                ),
              ),
              // Send order button
              AppButton(
                label: orderData.isBuy ? l10n.sendBuyOrder : l10n.sendSellOrder,
                onPressed: () {
                  // TODO: Handle order submission
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(label: l10n.orderType, value: _getOrderTypeLabel(l10n)),
        _buildDetailRow(
          label: l10n.numberOfShares,
          value: Formatters.formatNumber(orderData.numberOfShares),
        ),
        Container(height: 0.5, color: AppColors.surface),
        _buildDetailRow(
          label: l10n.sharesValue,
          value:
              '~${Formatters.formatPriceWithCurrency(orderData.sharesValue)}',
        ),
        if (orderData.limitPrice != null)
          _buildDetailRow(
            label: l10n.limitPrice,
            value: Formatters.formatPriceWithCurrency(orderData.limitPrice!),
          ),
        if (orderData.stopPrice != null)
          _buildDetailRow(
            label: l10n.stopPrice,
            value: Formatters.formatPriceWithCurrency(orderData.stopPrice!),
          ),
        _buildDetailRow(
          label: l10n.expiration,
          value: _getExpirationLabel(l10n),
        ),
        _buildDetailRow(
          label: l10n.commission,
          value: orderData.commission == 0
              ? l10n.free
              : Formatters.formatPriceWithCurrency(orderData.commission),
        ),
        _buildDetailRow(
          label: l10n.tax,
          value: '~${Formatters.formatPriceWithCurrency(orderData.tax)}',
        ),
        _buildDetailRow(
          label: l10n.total,
          value: '~${Formatters.formatPriceWithCurrency(orderData.total)}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // 12px as per Figma
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyLarge(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelLarge(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getOrderTypeLabel(AppLocalizations l10n) {
    final orderTypeLabel = orderData.orderType == OrderType.marketOrder
        ? l10n.marketOrder
        : orderData.orderType == OrderType.limit
        ? l10n.limit
        : orderData.orderType == OrderType.stop
        ? l10n.stop
        : l10n.stopLimit;
    return '$orderTypeLabel ${orderData.isBuy ? l10n.buy.toLowerCase() : l10n.sell.toLowerCase()}';
  }

  String _getExpirationLabel(AppLocalizations l10n) {
    switch (orderData.expirationType) {
      case ExpirationType.never:
        return l10n.never;
      case ExpirationType.endOfDay:
        return l10n.endOfDay;
    }
  }
}
