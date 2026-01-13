/// Global formatting utilities for numbers, prices, and values
class Formatters {
  Formatters._();

  /// Formats a number with comma separators (e.g., 1234567 -> "1,234,567")
  /// For numbers less than 1, returns as decimal with 2 decimal places
  static String formatNumber(int number) {
    // For very small numbers, show as decimal
    if (number < 1) {
      return number.toStringAsFixed(2);
    }
    // For larger numbers, format with commas
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formats a double value as an integer with comma separators
  /// (e.g., 1234567.89 -> "1,234,567")
  static String formatValue(double value) {
    final integerValue = value.toInt();
    return integerValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formats a price with 1 decimal place and comma separators
  /// (e.g., 1234.56 -> "1,234.5")
  static String formatPrice(double price) {
    final parts = price.toStringAsFixed(1).split('.');
    final integerPart = int.parse(parts[0]);
    return '${integerPart.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}.${parts[1]}';
  }

  /// Formats a price with currency symbol and appropriate decimal places
  /// For prices < 1: shows 4 decimal places
  /// For prices >= 1: shows 2 decimal places with comma separators
  /// (e.g., 0.1234 -> "0.1234", 1234.56 -> "$1,234.56")
  static String formatPriceWithCurrency(double price) {
    if (price < 1) {
      return price.toStringAsFixed(4);
    }
    final parts = price.toStringAsFixed(2).split('.');
    final integerPart = int.parse(parts[0]);
    return '\$${integerPart.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}.${parts[1]}';
  }

  /// Formats a price with currency symbol and 1 decimal place
  /// (e.g., 1234.56 -> "$1,234.5")
  static String formatPriceWithCurrencyOneDecimal(double price) {
    final parts = price.toStringAsFixed(1).split('.');
    final integerPart = int.parse(parts[0]);
    return '\$${integerPart.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}.${parts[1]}';
  }
}

