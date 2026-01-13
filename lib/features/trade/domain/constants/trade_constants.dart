/// Trade feature constants
/// Centralized location for all hardcoded trade-related values
class TradeConstants {
  TradeConstants._();

  // Default values
  static const double defaultMaxValue = 500000.0;
  static const double defaultBalance = 412032.0;
  static const String defaultExecutionTime = '10h 11 min';

  // Trading fees
  static const double taxRate = 0.001; // 0.1% tax
  static const double commissionRate = 0.0; // Free commission

  // Default initial values
  static const double defaultValue = 300000.0;
  static const double defaultLimitPrice = 24321.0;
  static const double defaultStopPrice = 24321.0;
}


