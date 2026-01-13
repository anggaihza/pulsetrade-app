import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/core/utils/formatters.dart';
import 'package:pulsetrade_app/features/trade/domain/models/stock_data.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Reusable stock information card widget
/// Displays ticker, company name, price, and change information
class StockInfoCard extends StatelessWidget {
  final StockData stockData;

  const StockInfoCard({
    super.key,
    required this.stockData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.whiteNormal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stockData.ticker,
                  style: AppTextStyles.titleSmall(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  stockData.companyName,
                  style: AppTextStyles.bodySmall(color: AppColors.textLabel),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${Formatters.formatPrice(stockData.price)}',
                style: AppTextStyles.titleSmall(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${stockData.isPositive ? '+' : ''}${stockData.change.toStringAsFixed(1)}',
                    style: AppTextStyles.bodyMedium(
                      color: stockData.isPositive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${stockData.isPositive ? '+' : ''}${stockData.changePercentage.toStringAsFixed(2)}% ${l10n.today}',
                    style: AppTextStyles.bodyMedium(
                      color: stockData.isPositive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

