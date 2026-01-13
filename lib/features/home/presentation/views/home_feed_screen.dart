import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/home_feed_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/feed_item_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/comments_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/chart_data_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/bottom_navigation_bar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/interaction_sidebar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/news_bottom_sheet.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_chart_widget.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_description.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/video_player_widget.dart';
import 'package:pulsetrade_app/features/profile/presentation/views/profile_screen.dart';
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
  int _currentFeedIndex = 0;
  bool _isChartExpanded = false;
  bool _isLiked = false;
  bool _isBookmarked = false;
  double _videoProgress = 0.0;
  bool _isPageActive = true;
  bool _isSeeking = false; // Track if user is currently seeking/dragging
  double? _lastSeekedProgress; // Track last seeked position to prevent override
  DateTime? _lastSeekTime; // Track when last seek happened

  late PageController _pageController;

  // Track video controllers per index for seeking
  final Map<int, VideoPlayerController> _videoControllers = {};

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
    return Stack(
      children: [
        // PageView with swipeable content
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: feedItems.length,
          onPageChanged: (index) {
            setState(() {
              _currentFeedIndex = index;
              _isChartExpanded = false;
              _videoProgress = 0.0;
              _isSeeking = false;
              _lastSeekedProgress = null;
              _lastSeekTime = null;
              // Clean up controllers for videos that are far from current (keep only current ± 1)
              final controllersToRemove = <int>[];
              _videoControllers.forEach((videoIndex, controller) {
                final distance = (videoIndex - index).abs();
                if (distance > 1) {
                  // Mark controllers that are more than 1 video away for removal
                  controllersToRemove.add(videoIndex);
                  // Dispose will be handled by the video player widget
                }
              });
              // Remove from map (disposal is handled by video player widget)
              for (final videoIndex in controllersToRemove) {
                _videoControllers.remove(videoIndex);
              }
            });
          },
          itemBuilder: (context, index) {
            final feedItemAsync = ref.watch(feedItemProvider(index));

            return feedItemAsync.when(
              data: (FeedItemData feedItem) =>
                  _buildFeedItem(context, feedItem, index),
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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Search button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
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
                  GestureDetector(
                    onTap: () async {
                      // Pause video while navigating away from home
                      final controller = _videoControllers[_currentFeedIndex];
                      controller?.pause();
                      setState(() {
                        _isPageActive = false;
                      });

                      await context.push(ProfileScreen.routePath);

                      if (!mounted) return;

                      // Resume video when coming back to home
                      setState(() {
                        _isPageActive = true;
                      });
                      final currentController =
                          _videoControllers[_currentFeedIndex];
                      if (currentController != null &&
                          currentController.value.isInitialized) {
                        currentController.play();
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        TablerIcons.user,
                        size: 24,
                        color: AppColors.whiteNormal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedItem(
    BuildContext context,
    FeedItemData feedItem,
    int index,
  ) {
    final stock = feedItem.stock;
    final chartData = feedItem.chartData;
    final newsEvents = feedItem.newsEvents;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe left to navigate to trade screen
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -500) {
          _navigateToTradeScreen(stock);
        }
      },
      child: Stack(
        children: [
          // Video background
          Positioned.fill(
            child: StockVideoPlayer(
              videoUrl: stock.videoUrl,
              isPlaying: _isPageActive && index == _currentFeedIndex,
              onProgressUpdate: (progress) {
                // Only update progress for the current video and when not seeking
                if (index == _currentFeedIndex && mounted && !_isSeeking) {
                  // Verify this progress update is from the current video's controller
                  final currentController =
                      _videoControllers[_currentFeedIndex];
                  if (currentController != null &&
                      currentController.value.isInitialized) {
                    // If we recently seeked, ignore progress updates that are too different
                    // This prevents old progress updates from overriding the seek position
                    if (_lastSeekTime != null &&
                        DateTime.now().difference(_lastSeekTime!) <
                            const Duration(milliseconds: 500)) {
                      if (_lastSeekedProgress != null) {
                        final progressDiff = (progress - _lastSeekedProgress!)
                            .abs();
                        // If progress is significantly different from seeked position, ignore it
                        if (progressDiff > 0.1) {
                          return; // Ignore this update
                        }
                      }
                    }
                    // Update immediately without deferring to avoid delays
                    setState(() {
                      _videoProgress = progress;
                    });
                  }
                }
              },
              onControllerReady: (controller) {
                // Track video controller for this specific video index
                if (controller != null) {
                  // Defer setState to avoid calling during widget tree finalization
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _videoControllers[index] = controller;
                      });
                    }
                  });
                }
                // Note: We don't handle controller == null here to avoid setState during disposal
                // Controllers are cleaned up when video URL changes or page changes
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
                      AppColors.black.withValues(alpha: 0.4),
                      AppColors.black.withValues(alpha: 0.7),
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
                // Spacer for floating header
                const SizedBox(height: 80),

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
                                        ? AppColors.background.withValues(
                                            alpha: 0.9,
                                          )
                                        : AppColors.background.withValues(
                                            alpha: 0.5,
                                          ),
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
                                                color: AppColors.surface,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            stock.ticker,
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
                                              stock.ticker,
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
                                                  color: AppColors.surface,
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
                                                  chartData: chartData,
                                                  isExpanded: false,
                                                  newsEvents: newsEvents,
                                                  onNewsEventTap: (event) {
                                                    _handleNewsEventTap(
                                                      event,
                                                      stock.ticker,
                                                    );
                                                  },
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
                                                      chartData: chartData,
                                                      isExpanded: true,
                                                      newsEvents: newsEvents,
                                                      onNewsEventTap: (event) {
                                                        _handleNewsEventTap(
                                                          event,
                                                          stock.ticker,
                                                        );
                                                      },
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
                                            stock.price.toStringAsFixed(2),
                                            style: AppTextStyles.labelLarge(
                                              color: AppColors.textPrimary,
                                            ).copyWith(fontSize: 14),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${stock.change >= 0 ? '+' : ''}${stock.change.toStringAsFixed(2)}',
                                            style: AppTextStyles.labelSmall(
                                              color: stock.isPositive
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
                                              color: AppColors.surface,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex:
                                                      (stock.sentimentScore *
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
                                                      ((1 - stock.sentimentScore) *
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
                                            stock.sentiment,
                                            style: AppTextStyles.bodySmall(
                                              color: AppColors.textLabel,
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
                                title: stock.newsTitle,
                                description: stock.newsDescription,
                                date: stock.date,
                                onMoreToggle: _onDescriptionMoreToggle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right side - Interaction buttons
                        InteractionSidebar(
                          stats: stock.stats,
                          isLiked: _isLiked,
                          isBookmarked: _isBookmarked,
                          onLike: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                          onComment: () => _showComments(stock.ticker),
                          onBookmark: () {
                            setState(() {
                              _isBookmarked = !_isBookmarked;
                            });
                          },
                          onShare: () {
                            _handleShare(stock);
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
                  child: VideoProgressBar(
                    key: ValueKey('progress_$_currentFeedIndex'),
                    progress: _videoProgress,
                    onDragStart: () {
                      setState(() {
                        _isSeeking = true;
                      });
                    },
                    onDragEnd: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          setState(() {
                            _isSeeking = false;
                          });
                        }
                      });
                    },
                    onSeek: (progress) {
                      final controller = _videoControllers[_currentFeedIndex];
                      if (controller != null &&
                          controller.value.isInitialized &&
                          controller.value.duration.inMilliseconds > 0) {
                        final duration = controller.value.duration;
                        final position = duration * progress;
                        controller.seekTo(position);
                        setState(() {
                          _videoProgress = progress;
                          _lastSeekedProgress = progress;
                          _lastSeekTime = DateTime.now();
                        });
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() {
                              _isSeeking = false;
                              _lastSeekTime = null;
                              _lastSeekedProgress = null;
                            });
                          }
                        });
                      } else {
                        setState(() {
                          _isSeeking = false;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
