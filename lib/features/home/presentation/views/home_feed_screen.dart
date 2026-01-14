import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/home_feed_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/feed_item_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/comments_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/chart_data_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/feed_state_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/video_controller_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/bottom_navigation_bar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/feed_item_widget.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/gesture_hint_overlay.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/home_feed_header.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/news_bottom_sheet.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/gesture_hint_provider.dart';
import 'package:pulsetrade_app/features/trade/presentation/views/trade_screen.dart';

/// Main home screen with TikTok-style video feed
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routePath = '/home';
  static const String routeName = 'home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int _currentNavIndex = 0;
  double _videoProgress = 0.0;
  bool _isPageActive = true;
  bool _isSeeking = false; // Track if user is currently seeking/dragging
  double? _lastSeekedProgress; // Track last seeked position to prevent override
  DateTime? _lastSeekTime; // Track when last seek happened

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _isPageActive = state == AppLifecycleState.resumed;
    });
  }

  void _handleNewsEventTap(NewsEvent event, String ticker) {
    // Show news bottom sheet with news items for this stock
    final newsItemsAsync = ref.read(newsItemsProvider(ticker));
    newsItemsAsync.whenData((List<NewsItem> newsItems) {
      showNewsSheet(context, newsItems);
    });
  }

  void _navigateToTradeScreen(StockData stock) {
    context.push('${TradeScreen.routePath}?ticker=${stock.ticker}');
  }

  void _toggleChart() {
    ref.read(feedStateProvider.notifier).toggleChartExpanded();
  }

  void _onDescriptionMoreToggle() {
    // When "more" is toggled, collapse the chart
    ref.read(feedStateProvider.notifier).setChartExpanded(false);
  }

  void _showComments(String ticker) {
    final commentsAsync = ref.read(commentsProvider(ticker));
    commentsAsync.whenData((List<CommentData> comments) {
      showCommentsSheet(
        context,
        comments,
        onAddComment: () {
          // TODO: Implement add comment
        },
        onLikeComment: (commentId) {
          // TODO: Implement like comment
        },
      );
    });
  }

  void _handleShare(StockData stock) {
    final changeSymbol = stock.isPositive ? '+' : '';
    final shareText =
        '''📈 ${stock.ticker} - $changeSymbol${stock.changePercentage.toStringAsFixed(2)}%

💰 Price: \$${stock.price.toStringAsFixed(2)} ($changeSymbol\$${stock.change.abs().toStringAsFixed(2)})

📰 ${stock.newsTitle}

${stock.newsDescription}

Shared via PulseTrade 📱''';

    Share.share(shareText, subject: '${stock.ticker} Stock Update');
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(homeFeedProvider(0));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: feedAsync.when(
        data: (List<StockData> feedItems) =>
            _buildFeedContent(context, feedItems),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Text(
            'Error loading feed: $error',
            style: AppTextStyles.bodyLarge(color: AppColors.error),
          ),
        ),
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

  Widget _buildFeedContent(BuildContext context, List<StockData> feedItems) {
    final gestureHintShownAsync = ref.watch(gestureHintShownProvider);

    return Stack(
      children: [
        // PageView with swipeable content
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: feedItems.length,
          onPageChanged: (index) {
            setState(() {
              ref.read(feedStateProvider.notifier).setCurrentFeedIndex(index);
              ref.read(feedStateProvider.notifier).setChartExpanded(false);
              _videoProgress = 0.0;
              _isSeeking = false;
              _lastSeekedProgress = null;
              _lastSeekTime = null;
              // Clean up controllers for videos that are far from current (keep only current ± 1)
              ref
                  .read(videoControllerProvider)
                  .retainWhere((videoIndex) => (videoIndex - index).abs() <= 1);
            });
          },
          itemBuilder: (context, index) {
            final feedItemAsync = ref.watch(feedItemProvider(index));

            return feedItemAsync.when(
              data: (FeedItemData feedItem) => FeedItemWidget(
                feedItem: feedItem,
                index: index,
                isPageActive: _isPageActive,
                videoProgress: _videoProgress,
                isSeeking: _isSeeking,
                lastSeekedProgress: _lastSeekedProgress,
                lastSeekTime: _lastSeekTime,
                onNavigateToTrade: () => _navigateToTradeScreen(feedItem.stock),
                onToggleChart: _toggleChart,
                onDescriptionMoreToggle: _onDescriptionMoreToggle,
                onShowComments: _showComments,
                onShare: _handleShare,
                onNewsEventTap: _handleNewsEventTap,
                onSeekingChanged: (isSeeking) {
                  setState(() {
                    _isSeeking = isSeeking;
                  });
                },
                onVideoProgressChanged: (progress) {
                  setState(() {
                    _videoProgress = progress;
                  });
                },
                onLastSeekedProgressChanged: (progress) {
                  setState(() {
                    _lastSeekedProgress = progress;
                  });
                },
                onLastSeekTimeChanged: (time) {
                  setState(() {
                    _lastSeekTime = time;
                  });
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) => Center(
                child: Text(
                  'Error loading item: $error',
                  style: AppTextStyles.bodyLarge(color: AppColors.error),
                ),
              ),
            );
          },
        ),

        // Floating header buttons (fixed, don't scroll)
        HomeFeedHeader(
          isPageActive: _isPageActive,
          onPageActiveChanged: (isActive) {
            setState(() {
              _isPageActive = isActive;
            });
          },
        ),

        // Gesture hint overlay (shown only on first entry)
        gestureHintShownAsync.when(
          data: (hasShown) {
            if (hasShown) {
              return const SizedBox.shrink();
            }
            return GestureHintOverlay(
              onDismiss: () {
                ref.read(gestureHintNotifierProvider).markAsShown();
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
