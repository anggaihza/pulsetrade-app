import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/stocks/domain/models/stock_info.dart';

/// Widget displaying dividend information with pie chart
///
/// Shows:
/// - Pie chart with earning retained and payout ratio
/// - Legend for chart segments
/// - Last payment and last ex-date information
class DividendInfoWidget extends StatelessWidget {
  const DividendInfoWidget({super.key, required this.dividendInfo});

  final DividendInfo dividendInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.only(top: 12),
            width: 180,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: PieChart(
                    PieChartData(
                      sections: _createSections(),
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                Text(
                  '${dividendInfo.earningRetainedPercent.toInt()}%',
                  style: AppTextStyles.titleMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: const Color(0xFF2979FF),
              label: 'Earning retained',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: AppColors.textLabel,
              label: 'Payout ratio (TTM)',
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dividend details
        Column(
          children: [
            _buildDividendRow(
              label: 'Last payment',
              value: dividendInfo.lastPayment ?? '-',
            ),
            const SizedBox(height: 8),
            _buildDividendRow(
              label: 'Last ex-date',
              value: dividendInfo.lastExDate ?? '-',
            ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _createSections() {
    const outerRadius = 15.0;

    return [
      PieChartSectionData(
        value: dividendInfo.earningRetainedPercent,
        color: AppColors.primary, // Primary blue - matching investment donut
        radius: outerRadius,
        showTitle: false,
      ),
      PieChartSectionData(
        value: dividendInfo.payoutRatioPercent,
        color: const Color(
          0xFFBDBDBD,
        ), // Light grey - matching investment donut background
        radius: outerRadius,
        showTitle: false,
      ),
    ];
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDividendRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
