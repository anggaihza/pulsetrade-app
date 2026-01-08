import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// Stock information card showing ticker, price, change, and sentiment
class StockInfoCard extends StatelessWidget {
  final StockData stock;

  const StockInfoCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticker symbol
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF2C2C2C), width: 0.5),
              ),
            ),
            child: Text(
              stock.ticker,
              style: AppTextStyles.headlineLarge(
                color: AppColors.textPrimary,
              ).copyWith(fontSize: 24),
            ),
          ),
          const SizedBox(height: 10),

          // Price and change
          Row(
            children: [
              Text(
                stock.price.toStringAsFixed(2),
                style: AppTextStyles.labelLarge(
                  color: AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                '${stock.change >= 0 ? '+' : ''}${stock.change.toStringAsFixed(2)}',
                style: AppTextStyles.labelSmall(
                  color: stock.isPositive ? AppColors.success : AppColors.error,
                ).copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sentiment bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    // Positive section
                    Expanded(
                      flex: (stock.sentimentScore * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // Negative section
                    Expanded(
                      flex: ((1 - stock.sentimentScore) * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Sentiment label
              Text(
                stock.sentiment,
                style: AppTextStyles.bodySmall(color: const Color(0xFFAEAEAE)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
