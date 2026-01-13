/// Stock data model for trade screens
class StockData {
  final String ticker;
  final String companyName;
  final double price;
  final double change;
  final double changePercentage;
  final bool isPositive;

  const StockData({
    required this.ticker,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercentage,
    required this.isPositive,
  });
}

