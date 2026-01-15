import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/stocks/domain/models/stock_info.dart';

/// Widget displaying financial statements with bar chart
/// 
/// Features:
/// - Filter tabs: Income Statement, Balance sheet, Cash flow
/// - Bar chart showing Revenue and Net income over years
/// - Legend for chart series
class FinancialsWidget extends ConsumerStatefulWidget {
  const FinancialsWidget({
    super.key,
    required this.financials,
  });

  final Financials financials;

  @override
  ConsumerState<FinancialsWidget> createState() => _FinancialsWidgetState();
}

class _FinancialsWidgetState extends ConsumerState<FinancialsWidget> {
  late FinancialStatementType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.financials.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = _getDataPointsForType(_selectedType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financials',
          style: AppTextStyles.titleSmall(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Filter tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterTab(
                label: 'Income Statement',
                isSelected: _selectedType == FinancialStatementType.incomeStatement,
                onTap: () => setState(() {
                  _selectedType = FinancialStatementType.incomeStatement;
                }),
              ),
              const SizedBox(width: 10),
              _buildFilterTab(
                label: 'Balance sheet',
                isSelected: _selectedType == FinancialStatementType.balanceSheet,
                onTap: () => setState(() {
                  _selectedType = FinancialStatementType.balanceSheet;
                }),
              ),
              const SizedBox(width: 10),
              _buildFilterTab(
                label: 'Cash flow',
                isSelected: _selectedType == FinancialStatementType.cashFlow,
                onTap: () => setState(() {
                  _selectedType = FinancialStatementType.cashFlow;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Chart header with period selector
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Annual',
              style: AppTextStyles.bodyMedium(
                color: AppColors.textLabel,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textLabel,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Bar chart
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          value.toInt().toString(),
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textLabel,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < dataPoints.length) {
                        return Text(
                          dataPoints[index].year,
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.textLabel,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.surface,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.surface,
                    width: 1,
                  ),
                ),
              ),
              barGroups: _buildBarGroups(dataPoints),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: const Color(0xFF2979FF), // Primary blue
              label: 'Revenue',
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: AppColors.textLabel, // Gray
              label: 'Net income',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0E2A59) // Foundation/Primary/Darker
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: isSelected ? AppColors.textPrimary : AppColors.textLabel,
          ).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  List<FinancialDataPoint> _getDataPointsForType(FinancialStatementType type) {
    switch (type) {
      case FinancialStatementType.incomeStatement:
        return widget.financials.incomeStatement;
      case FinancialStatementType.balanceSheet:
        return widget.financials.balanceSheet;
      case FinancialStatementType.cashFlow:
        return widget.financials.cashFlow;
    }
  }

  List<BarChartGroupData> _buildBarGroups(List<FinancialDataPoint> dataPoints) {
    return dataPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.revenue,
            color: const Color(0xFF2979FF), // Primary blue
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data.netIncome,
            color: AppColors.textLabel, // Gray
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 2,
      );
    }).toList();
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

