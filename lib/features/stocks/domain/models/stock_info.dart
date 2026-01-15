/// Stock information data model
/// Contains key ratios, dividend information, and financials
class StockInfo {
  final KeyRatios keyRatios;
  final DividendInfo dividendInfo;
  final Financials financials;

  const StockInfo({
    required this.keyRatios,
    required this.dividendInfo,
    required this.financials,
  });
}

/// Key financial ratios
class KeyRatios {
  final String marketCap;
  final String peRatio;
  final String revenue;
  final String eps;
  final String dividendYield;
  final String beta;

  const KeyRatios({
    required this.marketCap,
    required this.peRatio,
    required this.revenue,
    required this.eps,
    required this.dividendYield,
    required this.beta,
  });
}

/// Dividend information
class DividendInfo {
  final double earningRetainedPercent; // Percentage (0-100)
  final double payoutRatioPercent; // Percentage (0-100)
  final String? lastPayment;
  final String? lastExDate;

  const DividendInfo({
    required this.earningRetainedPercent,
    required this.payoutRatioPercent,
    this.lastPayment,
    this.lastExDate,
  });
}

/// Financial statement data
class Financials {
  final FinancialStatementType selectedType;
  final List<FinancialDataPoint> incomeStatement;
  final List<FinancialDataPoint> balanceSheet;
  final List<FinancialDataPoint> cashFlow;

  const Financials({
    required this.selectedType,
    required this.incomeStatement,
    required this.balanceSheet,
    required this.cashFlow,
  });
}

/// Type of financial statement
enum FinancialStatementType {
  incomeStatement,
  balanceSheet,
  cashFlow,
}

/// Financial data point for charts
class FinancialDataPoint {
  final String year;
  final double revenue;
  final double netIncome;

  const FinancialDataPoint({
    required this.year,
    required this.revenue,
    required this.netIncome,
  });
}

