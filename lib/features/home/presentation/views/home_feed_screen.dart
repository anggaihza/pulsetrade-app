import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/bottom_navigation_bar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/interaction_sidebar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_chart_widget.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_description.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_info_card.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/video_player_widget.dart';

/// Main home feed screen with TikTok-style video feed
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  static const String routePath = '/feed';
  static const String routeName = 'feed';

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _currentNavIndex = 0;
  int _currentFeedIndex = 0;
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
          comment: 'proident anim culpa pariatur mollit do pariatur amet consequat amet',
          timestamp: '11:09',
          likes: 8,
          replies: 7,
          isLiked: false,
        ),
        CommentData(
          id: '2',
          userName: 'John Doeni',
          userAvatar: '',
          comment: 'proident anim culpa pariatur mollit do pariatur amet consequat amet',
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
  List<ChartDataPoint> get _currentChartData => _chartDataList[_currentFeedIndex];

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
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
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
                        // Left side - Stock info, chart, and description
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stock info card
                              StockInfoCard(
                                stock: _currentStock,
                              ),
                              const SizedBox(height: 16),
                              
                              // Chart widget (expandable/collapsible)
                              if (_isChartExpanded)
                                StockChartWidget(
                                  ticker: _currentStock.ticker,
                                  currentPrice: _currentStock.price,
                                  changePercentage: _currentStock.changePercentage,
                                  chartData: _currentChartData,
                                  isExpanded: _isChartExpanded,
                                  onToggleExpand: _toggleChart,
                                )
                              else
                                StockChartWidget(
                                  ticker: _currentStock.ticker,
                                  currentPrice: _currentStock.price,
                                  changePercentage: _currentStock.changePercentage,
                                  chartData: _currentChartData,
                                  isExpanded: false,
                                  onToggleExpand: _toggleChart,
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

