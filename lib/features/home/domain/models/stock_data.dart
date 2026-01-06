/// Model for stock information displayed in the feed
class StockData {
  final String ticker;
  final double price;
  final double change;
  final double changePercentage;
  final bool isPositive;
  final String sentiment; // "Bullish", "Bearish", "Neutral"
  final double sentimentScore; // 0.0 to 1.0 for the sentiment bar
  final String newsTitle;
  final String newsDescription;
  final String date;
  final String videoUrl;
  final String? thumbnailUrl;
  final StockStats stats;

  StockData({
    required this.ticker,
    required this.price,
    required this.change,
    required this.changePercentage,
    required this.isPositive,
    required this.sentiment,
    required this.sentimentScore,
    required this.newsTitle,
    required this.newsDescription,
    required this.date,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.stats,
  });
}

/// Social interaction statistics
class StockStats {
  final int likes;
  final int comments;
  final int bookmarks;
  final int shares;

  StockStats({
    required this.likes,
    required this.comments,
    required this.bookmarks,
    required this.shares,
  });
}

/// Chart data point
class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({
    required this.date,
    required this.value,
  });
}

/// Comment data
class CommentData {
  final String id;
  final String userName;
  final String userAvatar;
  final String comment;
  final String timestamp;
  final int likes;
  final int replies;
  final bool isLiked;

  CommentData({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.comment,
    required this.timestamp,
    required this.likes,
    required this.replies,
    this.isLiked = false,
  });
}

