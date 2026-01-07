import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/bottom_navigation_bar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/interaction_sidebar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_chart_widget.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_description.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/video_player_widget.dart';

/// Main home screen with TikTok-style video feed
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routePath = '/home';
  static const String routeName = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final int _currentFeedIndex = 0;
  bool _isChartExpanded = false;
  bool _isLiked = false;
  bool _isBookmarked = false;
  double _videoProgress = 0.0;

  // Mock data - In production, this would come from a provider/repository
  late List<StockData> _stockFeed;
  late List<List<CommentData>> _commentsList;
  late List<List<ChartDataPoint>> _chartDataList;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    // Generate mock chart data
    _chartDataList = [
      List.generate(30, (i) {
        return ChartDataPoint(
          date: DateTime.now().subtract(Duration(days: 30 - i)),
          value: 150 + (i * 2.0) + (i % 5 * 5),
        );
      }),
    ];

    // Mock stock data
    _stockFeed = [
      StockData(
        ticker: 'TSLA',
        price: 177.12,
        change: -1.28,
        changePercentage: -1.28,
        isPositive: false,
        sentiment: 'Bullish',
        sentimentScore: 0.65,
        newsTitle: 'News Title',
        newsDescription:
            'est ex minim et ea in ullamco esse commodo sint ullamco incididunt mollit velit velit deserunt minim veniam cillum ad ullamco incididunt molli',
        date: '19 Aug 2025',
        videoUrl: 'assets/videos/stock_video.mp4',
        stats: StockStats(
          likes: 102,
          comments: 21,
          bookmarks: 1201,
          shares: 1201,
        ),
      ),
    ];

    // Mock comments
    _commentsList = [
      [
        CommentData(
          id: '1',
          userName: 'John Doeni',
          userAvatar: '',
          comment:
              'proident anim culpa pariatur mollit do pariatur amet consequat amet',
          timestamp: '11:09',
          likes: 8,
          replies: 7,
          isLiked: false,
        ),
        CommentData(
          id: '2',
          userName: 'John Doeni',
          userAvatar: '',
          comment:
              'proident anim culpa pariatur mollit do pariatur amet consequat amet',
          timestamp: '11:09',
          likes: 8,
          replies: 0,
          isLiked: true,
        ),
      ],
    ];
  }

  StockData get _currentStock => _stockFeed[_currentFeedIndex];
  List<CommentData> get _currentComments => _commentsList[_currentFeedIndex];
  List<ChartDataPoint> get _currentChartData =>
      _chartDataList[_currentFeedIndex];

  void _toggleChart() {
    setState(() {
      _isChartExpanded = !_isChartExpanded;
    });
  }

  void _onDescriptionMoreToggle() {
    // When "more" is toggled, collapse the chart if it's expanded
    if (_isChartExpanded) {
      setState(() {
        _isChartExpanded = false;
      });
    }
  }

  void _showComments() {
    showCommentsSheet(
      context,
      _currentComments,
      onAddComment: () {
        // TODO: Implement add comment
      },
      onLikeComment: (commentId) {
        // TODO: Implement like comment
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Video background
          Positioned.fill(
            child: StockVideoPlayer(
              videoUrl: _currentStock.videoUrl,
              onProgressUpdate: (progress) {
                setState(() {
                  _videoProgress = progress;
                });
              },
            ),
          ),

          // Gradient overlay for better text readability (subtle, bottom only)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.6, 0.85, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Content overlay
          SafeArea(
            child: Column(
              children: [
                // Header with search and profile
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Search button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          TablerIcons.search,
                          size: 24,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Profile button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C2C2C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          TablerIcons.user,
                          size: 24,
                          color: Color(0xFFAEAEAE),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left side - Combined stock info/chart and description
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Single unified container for both expanded and collapsed states
                              GestureDetector(
                                onTap: _toggleChart,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _isChartExpanded
                                        ? AppColors.background.withOpacity(0.9)
                                        : AppColors.background.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Ticker row (with mini chart when collapsed) - Animated
                                      AnimatedCrossFade(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        sizeCurve: Curves.easeInOut,
                                        firstCurve: Curves.easeInOut,
                                        secondCurve: Curves.easeInOut,
                                        crossFadeState: _isChartExpanded
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        firstChild: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color(0xFF2C2C2C),
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            _currentStock.ticker,
                                            style: AppTextStyles.headlineLarge(
                                              color: AppColors.textPrimary,
                                            ).copyWith(fontSize: 24),
                                          ),
                                        ),
                                        secondChild: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Ticker text (no border)
                                            Text(
                                              _currentStock.ticker,
                                              style:
                                                  AppTextStyles.headlineLarge(
                                                    color:
                                                        AppColors.textPrimary,
                                                  ).copyWith(fontSize: 24),
                                            ),

                                            // Mini chart with border container
                                            Container(
                                              width: 118,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF2C2C2C,
                                                  ),
                                                  width: 0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              alignment: Alignment.bottomCenter,
                                              child: SizedBox(
                                                width: 200,
                                                height: 84.925,
                                                child: StockChartWidget(
                                                  chartData: _currentChartData,
                                                  isExpanded: false,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Chart (only when expanded) - Animated
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        child: _isChartExpanded
                                            ? Column(
                                                children: [
                                                  const SizedBox(height: 8),
                                                  SizedBox(
                                                    height: 164.5,
                                                    child: StockChartWidget(
                                                      chartData:
                                                          _currentChartData,
                                                      isExpanded: true,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                      ),

                                      const SizedBox(height: 8),

                                      // Price and change (always visible, full width)
                                      Row(
                                        children: [
                                          Text(
                                            _currentStock.price.toStringAsFixed(
                                              2,
                                            ),
                                            style: AppTextStyles.labelLarge(
                                              color: AppColors.textPrimary,
                                            ).copyWith(fontSize: 14),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_currentStock.change >= 0 ? '+' : ''}${_currentStock.change.toStringAsFixed(2)}',
                                            style: AppTextStyles.labelSmall(
                                              color: _currentStock.isPositive
                                                  ? AppColors.success
                                                  : AppColors.error,
                                            ).copyWith(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Sentiment bar (always visible, full width)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2C2C2C),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex:
                                                      (_currentStock
                                                                  .sentimentScore *
                                                              100)
                                                          .round(),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.success,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            1,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex:
                                                      ((1 -
                                                                  _currentStock
                                                                      .sentimentScore) *
                                                              100)
                                                          .round(),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.error,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            1,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _currentStock.sentiment,
                                            style: AppTextStyles.bodySmall(
                                              color: const Color(0xFFAEAEAE),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Description
                              StockDescription(
                                title: _currentStock.newsTitle,
                                description: _currentStock.newsDescription,
                                date: _currentStock.date,
                                onMoreToggle: _onDescriptionMoreToggle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right side - Interaction buttons
                        InteractionSidebar(
                          stats: _currentStock.stats,
                          isLiked: _isLiked,
                          isBookmarked: _isBookmarked,
                          onLike: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                          onComment: _showComments,
                          onBookmark: () {
                            setState(() {
                              _isBookmarked = !_isBookmarked;
                            });
                          },
                          onShare: () {
                            // TODO: Implement share
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Video progress bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  color: AppColors.background,
                  child: VideoProgressBar(progress: _videoProgress),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          // TODO: Navigate to different sections
        },
      ),
    );
  }
}
