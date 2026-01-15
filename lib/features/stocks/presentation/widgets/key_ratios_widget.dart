import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/stocks/domain/models/stock_info.dart';

/// Widget displaying key financial ratios
/// 
/// Displays ratios in a 2-column grid:
/// - Market Cap, P/E ratio
/// - Revenue, EPS
/// - Dividend yield, Beta
class KeyRatiosWidget extends StatelessWidget {
  const KeyRatiosWidget({
    super.key,
    required this.keyRatios,
  });

  final KeyRatios keyRatios;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Ratios',
            style: AppTextStyles.titleSmall(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // First row: Market Cap, P/E ratio
          _buildRatioRow(
            label: 'Market Cap',
            value: keyRatios.marketCap,
            label2: 'P/E ratio',
            value2: keyRatios.peRatio,
          ),
          const SizedBox(height: 16),
          // Second row: Revenue, EPS
          _buildRatioRow(
            label: 'Revenue',
            value: keyRatios.revenue,
            label2: 'EPS',
            value2: keyRatios.eps,
          ),
          const SizedBox(height: 16),
          // Third row: Dividend yield, Beta
          _buildRatioRow(
            label: 'Dividend yield',
            value: keyRatios.dividendYield,
            label2: 'Beta',
            value2: keyRatios.beta,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRatioRow({
    required String label,
    required String value,
    required String label2,
    required String value2,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Expanded(
            child: _buildRatioItem(label: label, value: value),
          ),
          Expanded(
            child: _buildRatioItem(label: label2, value: value2),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

