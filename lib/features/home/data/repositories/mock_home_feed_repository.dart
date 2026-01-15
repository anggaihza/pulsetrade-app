import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/domain/repositories/home_feed_repository.dart';

/// Mock implementation of HomeFeedRepository
/// Provides hardcoded mock data for development and testing
class MockHomeFeedRepository implements HomeFeedRepository {
  MockHomeFeedRepository._();
  
  static final MockHomeFeedRepository _instance = MockHomeFeedRepository._();
  
  factory MockHomeFeedRepository() => _instance;

  // Cache for generated data to avoid regenerating on every call
  List<StockData>? _cachedFeedItems;
  Map<String, List<CommentData>>? _cachedComments;
  Map<String, List<ChartDataPoint>>? _cachedChartData;
  Map<String, List<NewsEvent>>? _cachedNewsEvents;
  Map<String, List<NewsItem>>? _cachedNewsItems;

  @override
  Future<List<StockData>> getFeedItems({
    int page = 0,
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Return cached data if available
    if (_cachedFeedItems != null) {
      final startIndex = page * limit;
      final endIndex = (startIndex + limit).clamp(0, _cachedFeedItems!.length);
      if (startIndex < _cachedFeedItems!.length) {
        return _cachedFeedItems!.sublist(startIndex, endIndex);
      }
      return [];
    }

    // Generate mock stock data
    _cachedFeedItems = _generateMockStockData();
    
    final startIndex = page * limit;
    final endIndex = (startIndex + limit).clamp(0, _cachedFeedItems!.length);
    if (startIndex < _cachedFeedItems!.length) {
      return _cachedFeedItems!.sublist(startIndex, endIndex);
    }
    return [];
  }

  @override
  Future<List<CommentData>> getComments(String stockId) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (_cachedComments == null) {
      _cachedComments = _generateMockComments();
    }

    return _cachedComments![stockId] ?? [];
  }

  @override
  Future<List<ChartDataPoint>> getChartData(String ticker) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (_cachedChartData == null) {
      _cachedChartData = _generateMockChartData();
    }

    return _cachedChartData![ticker] ?? [];
  }

  @override
  Future<List<NewsEvent>> getNewsEvents(String ticker) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (_cachedNewsEvents == null) {
      _cachedNewsEvents = _generateMockNewsEvents();
    }

    return _cachedNewsEvents![ticker] ?? [];
  }

  @override
  Future<List<NewsItem>> getNewsItems(String ticker) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (_cachedNewsItems == null) {
      _cachedNewsItems = _generateMockNewsItems();
    }

    return _cachedNewsItems![ticker] ?? [];
  }

  // Private methods to generate mock data

  List<StockData> _generateMockStockData() {
    return [
      StockData(
        ticker: 'TSLA',
        price: 177.12,
        change: -1.28,
        changePercentage: -1.28,
        isPositive: false,
        sentiment: 'Bullish',
        sentimentScore: 0.65,
        newsTitle: 'Tesla Stock Analysis',
        newsDescription:
            'Tesla shares decline amid production concerns, but analysts remain optimistic about long-term growth prospects and upcoming model releases',
        date: '19 Aug 2025',
        videoUrl:
            'https://f002.backblazeb2.com/file/creatomate-c8xg3hsxdu/c77f6589-a771-4a95-acbe-cbcedf37d662.mp4',
        stats: StockStats(
          likes: 1520,
          comments: 234,
          bookmarks: 892,
          shares: 445,
        ),
      ),
      StockData(
        ticker: 'NVDA',
        price: 485.22,
        change: 12.56,
        changePercentage: 2.66,
        isPositive: true,
        sentiment: 'Very Bullish',
        sentimentScore: 0.85,
        newsTitle: 'NVIDIA AI Boom Continues',
        newsDescription:
            'NVIDIA stock soars on AI chip demand as data centers worldwide rush to upgrade infrastructure for next-gen AI workloads',
        date: '21 Aug 2025',
        videoUrl:
            'https://resource2.heygen.ai/video/6d61ec3096534f1f8c1236da2bd45a02/720x1280.mp4',
        stats: StockStats(
          likes: 3890,
          comments: 678,
          bookmarks: 2341,
          shares: 1234,
        ),
      ),
      StockData(
        ticker: 'MSFT',
        price: 378.90,
        change: -0.45,
        changePercentage: -0.12,
        isPositive: false,
        sentiment: 'Neutral',
        sentimentScore: 0.52,
        newsTitle: 'Microsoft Azure Growth',
        newsDescription:
            'Microsoft cloud services show steady growth despite slight stock decline, with Azure gaining market share in enterprise sector',
        date: '22 Aug 2025',
        videoUrl:
            'https://resource2.heygen.ai/video/8d38aa7f7fbe4a5c83e85de1d7533536/720x1280.mp4',
        stats: StockStats(
          likes: 1876,
          comments: 345,
          bookmarks: 1123,
          shares: 567,
        ),
      ),
    ];
  }

  Map<String, List<CommentData>> _generateMockComments() {
    return {
      'TSLA': [
        CommentData(
          id: '1',
          userName: 'TechInvestor',
          userAvatar: '',
          comment:
              'Great buying opportunity at this price point! Long term hold 🚀',
          timestamp: '2h ago',
          likes: 145,
          replies: 12,
          isLiked: false,
        ),
        CommentData(
          id: '2',
          userName: 'MarketWatch_Pro',
          userAvatar: '',
          comment: 'Production numbers looking strong despite the dip',
          timestamp: '4h ago',
          likes: 89,
          replies: 5,
          isLiked: true,
        ),
      ],
      'NVDA': [
        CommentData(
          id: '5',
          userName: 'AI_Trader',
          userAvatar: '',
          comment: 'AI revolution is real and NVDA is leading the charge! 🤖',
          timestamp: '30m ago',
          likes: 456,
          replies: 34,
          isLiked: true,
        ),
        CommentData(
          id: '6',
          userName: 'ChipEnthusiast',
          userAvatar: '',
          comment: 'H100 demand through the roof, can\'t keep up with orders',
          timestamp: '1h ago',
          likes: 312,
          replies: 23,
          isLiked: false,
        ),
      ],
      'MSFT': [
        CommentData(
          id: '7',
          userName: 'CloudExpert',
          userAvatar: '',
          comment: 'Azure is quietly dominating enterprise cloud space',
          timestamp: '2h ago',
          likes: 198,
          replies: 15,
          isLiked: false,
        ),
        CommentData(
          id: '8',
          userName: 'ValueInvestor',
          userAvatar: '',
          comment: 'Undervalued compared to peers, great entry point',
          timestamp: '5h ago',
          likes: 134,
          replies: 9,
          isLiked: true,
        ),
      ],
    };
  }

  Map<String, List<ChartDataPoint>> _generateMockChartData() {
    // Chart data from Figma design (ConfigAndData-Line-Don't remove!)
    // Raw data is normalized 0-100, we'll map it to a price range
    final List<int> figmaChartData = [
      0, 0, 4, 11, 9, 8, 8, 8, 8, 6, 6, 7, 6, 10, 8, 16, 15, 19, 19, 26, 27,
      31, 30, 36, 39, 47, 53, 59, 58, 56, 60, 63, 61, 61, 59, 60, 60, 59, 62,
      67, 69, 73, 72, 70, 72, 77, 81, 81, 81, 83, 78, 79, 80, 81, 83, 84, 82,
      78, 74, 76, 76, 72, 67, 64, 64, 65, 66, 63, 64, 61, 62, 56, 54, 46, 47,
      49, 48, 42, 38, 39, 39, 41, 41, 42, 37, 31, 26, 27, 25, 20, 21, 22, 15,
      16, 16, 17, 13, 9, 10, 7,
    ];

    // Map Figma data (0-100) to price ranges for each stock
    // TSLA: Map to range 100-200 (matching Figma Y-axis 0-100)
    final tslaBasePrice = 100.0;
    final tslaPriceRange = 100.0;
    
    // NVDA: Map to range 350-450
    final nvdaBasePrice = 350.0;
    final nvdaPriceRange = 100.0;
    
    // MSFT: Map to range 300-400
    final msftBasePrice = 300.0;
    final msftPriceRange = 100.0;

    return {
      'TSLA': figmaChartData.asMap().entries.map((entry) {
        final normalizedValue = entry.value / 100.0;
        final price = tslaBasePrice + (normalizedValue * tslaPriceRange);
        return ChartDataPoint(
          date: DateTime.now().subtract(Duration(days: figmaChartData.length - 1 - entry.key)),
          value: price,
        );
      }).toList(),
      'NVDA': figmaChartData.asMap().entries.map((entry) {
        final normalizedValue = entry.value / 100.0;
        final price = nvdaBasePrice + (normalizedValue * nvdaPriceRange);
        return ChartDataPoint(
          date: DateTime.now().subtract(Duration(days: figmaChartData.length - 1 - entry.key)),
          value: price,
        );
      }).toList(),
      'MSFT': figmaChartData.asMap().entries.map((entry) {
        final normalizedValue = entry.value / 100.0;
        final price = msftBasePrice + (normalizedValue * msftPriceRange);
        return ChartDataPoint(
          date: DateTime.now().subtract(Duration(days: figmaChartData.length - 1 - entry.key)),
          value: price,
        );
      }).toList(),
    };
  }

  Map<String, List<NewsEvent>> _generateMockNewsEvents() {
    return {
      'TSLA': [
        NewsEvent(
          chartIndex: 29,
          title: 'Tesla Stock Analysis',
          date: DateTime(2025, 8, 19),
        ),
      ],
      'NVDA': [
        NewsEvent(
          chartIndex: 25,
          title: 'NVIDIA AI Boom Continues',
          date: DateTime(2025, 8, 21),
        ),
      ],
      'MSFT': [
        NewsEvent(
          chartIndex: 20,
          title: 'Microsoft Azure Growth',
          date: DateTime(2025, 8, 22),
        ),
      ],
    };
  }

  Map<String, List<NewsItem>> _generateMockNewsItems() {
    return {
      'TSLA': [
        NewsItem(
          id: '1',
          timestamp: '5:55 PM • Dec 3 • American News',
          headline: 'Mergers and acquisitions',
        ),
        NewsItem(
          id: '2',
          timestamp: '4:21 PM • Dec 3 • London Stock Exchange',
          headline: 'REG - UBS ETF MSCI EMU - Net Asset Value(s)',
        ),
        NewsItem(
          id: '3',
          timestamp: '4:40 PM • Dec 3 • dpa-AFX',
          headline: 'Liberty Global is Maintained at Neutral by UBS Software',
        ),
      ],
      'NVDA': [
        NewsItem(
          id: '4',
          timestamp: '3:15 PM • Dec 3 • Tech News',
          headline: 'NVIDIA AI Chip Demand Surges',
        ),
        NewsItem(
          id: '5',
          timestamp: '2:30 PM • Dec 3 • Market Watch',
          headline: 'Data Centers Rush to Upgrade Infrastructure',
        ),
      ],
      'MSFT': [
        NewsItem(
          id: '6',
          timestamp: '1:45 PM • Dec 3 • Cloud Weekly',
          headline: 'Microsoft Azure Gains Market Share',
        ),
        NewsItem(
          id: '7',
          timestamp: '12:20 PM • Dec 3 • Enterprise News',
          headline: 'Enterprise Sector Shows Steady Growth',
        ),
      ],
    };
  }
}

