import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/feed_item_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/feed_state_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/video_controller_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/interaction_sidebar.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_chart_widget.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/stock_description.dart';
import 'package:pulsetrade_app/features/home/presentation/widgets/video_player_widget.dart';

/// A single feed item widget displaying stock video, chart, and interactions.
///
/// This widget handles:
/// - Video playback with progress tracking
/// - Chart expansion/collapse
/// - Like/bookmark interactions
/// - News event taps
/// - Swipe gestures to navigate to trade screen
class FeedItemWidget extends ConsumerStatefulWidget {
  final FeedItemData feedItem;
  final int index;
  final bool isPageActive;
  final double videoProgress;
  final bool isSeeking;
  final double? lastSeekedProgress;
  final DateTime? lastSeekTime;
  final VoidCallback onNavigateToTrade;
  final VoidCallback? onNavigateToStocks;
  final VoidCallback onToggleChart;
  final VoidCallback onDescriptionMoreToggle;
  final void Function(String ticker) onShowComments;
  final void Function(StockData stock) onShare;
  final void Function(NewsEvent event, String ticker) onNewsEventTap;
  final ValueChanged<bool> onSeekingChanged;
  final ValueChanged<double> onVideoProgressChanged;
  final ValueChanged<double?> onLastSeekedProgressChanged;
  final ValueChanged<DateTime?> onLastSeekTimeChanged;

  const FeedItemWidget({
    super.key,
    required this.feedItem,
    required this.index,
    required this.isPageActive,
    required this.videoProgress,
    required this.isSeeking,
    this.lastSeekedProgress,
    this.lastSeekTime,
    required this.onNavigateToTrade,
    this.onNavigateToStocks,
    required this.onToggleChart,
    required this.onDescriptionMoreToggle,
    required this.onShowComments,
    required this.onShare,
    required this.onNewsEventTap,
    required this.onSeekingChanged,
    required this.onVideoProgressChanged,
    required this.onLastSeekedProgressChanged,
    required this.onLastSeekTimeChanged,
  });

  @override
  ConsumerState<FeedItemWidget> createState() => _FeedItemWidgetState();
}

class _FeedItemWidgetState extends ConsumerState<FeedItemWidget> {
  @override
  Widget build(BuildContext context) {
    final stock = widget.feedItem.stock;
    final chartData = widget.feedItem.chartData;
    final newsEvents = widget.feedItem.newsEvents;
    final isLiked = ref.watch(
      feedStateProvider.select(
        (state) => state.likedTickers.contains(stock.ticker),
      ),
    );
    final isBookmarked = ref.watch(
      feedStateProvider.select(
        (state) => state.bookmarkedTickers.contains(stock.ticker),
      ),
    );
    final currentIndex = ref.watch(
      feedStateProvider.select((state) => state.currentFeedIndex),
    );
    final registry = ref.read(videoControllerProvider);
    final isChartExpanded = ref.watch(
      feedStateProvider.select((state) => state.isChartExpanded),
    );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          // Swipe left to navigate to trade screen
          if (details.primaryVelocity! < -500) {
            widget.onNavigateToTrade();
          }
          // Swipe right to navigate to stocks screen
          else if (details.primaryVelocity! > 500) {
            widget.onNavigateToStocks?.call();
          }
        }
      },
      child: Stack(
        children: [
          // Video background
          Positioned.fill(
            child: StockVideoPlayer(
              videoUrl: stock.videoUrl,
              isPlaying: widget.isPageActive && widget.index == currentIndex,
              onProgressUpdate: (progress) {
                // Only update progress for the current video and when not seeking
                if (widget.index == currentIndex &&
                    mounted &&
                    !widget.isSeeking) {
                  // Verify this progress update is from the current video's controller
                  final currentController = registry.controllerForIndex(
                    currentIndex,
                  );
                  if (currentController != null &&
                      currentController.value.isInitialized) {
                    // If we recently seeked, ignore progress updates that are too different
                    // This prevents old progress updates from overriding the seek position
                    if (widget.lastSeekTime != null &&
                        DateTime.now().difference(widget.lastSeekTime!) <
                            const Duration(milliseconds: 500)) {
                      if (widget.lastSeekedProgress != null) {
                        final progressDiff =
                            (progress - widget.lastSeekedProgress!).abs();
                        // If progress is significantly different from seeked position, ignore it
                        if (progressDiff > 0.1) {
                          return; // Ignore this update
                        }
                      }
                    }
                    // Update immediately without deferring to avoid delays
                    widget.onVideoProgressChanged(progress);
                  }
                }
              },
              onControllerReady: (controller) {
                // Track video controller for this specific video index
                if (controller != null) {
                  // Defer setState to avoid calling during widget tree finalization
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      registry.setController(widget.index, controller);
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
                                onTap: widget.onToggleChart,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isChartExpanded
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
                                        crossFadeState: isChartExpanded
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
                                                    widget.onNewsEventTap(
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
                                        child: isChartExpanded
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
                                                        widget.onNewsEventTap(
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
                                onMoreToggle: widget.onDescriptionMoreToggle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right side - Interaction buttons
                        InteractionSidebar(
                          stats: stock.stats,
                          isLiked: isLiked,
                          isBookmarked: isBookmarked,
                          onLike: () {
                            ref
                                .read(feedStateProvider.notifier)
                                .toggleLike(stock.ticker);
                          },
                          onComment: () => widget.onShowComments(stock.ticker),
                          onBookmark: () {
                            ref
                                .read(feedStateProvider.notifier)
                                .toggleBookmark(stock.ticker);
                          },
                          onShare: () {
                            widget.onShare(stock);
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
                    key: ValueKey('progress_$currentIndex'),
                    progress: widget.videoProgress,
                    onDragStart: () {
                      widget.onSeekingChanged(true);
                    },
                    onDragEnd: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          widget.onSeekingChanged(false);
                        }
                      });
                    },
                    onSeek: (progress) {
                      final controller = registry.controllerForIndex(
                        currentIndex,
                      );
                      if (controller != null &&
                          controller.value.isInitialized &&
                          controller.value.duration.inMilliseconds > 0) {
                        final duration = controller.value.duration;
                        final position = duration * progress;
                        controller.seekTo(position);
                        widget.onVideoProgressChanged(progress);
                        widget.onLastSeekedProgressChanged(progress);
                        widget.onLastSeekTimeChanged(DateTime.now());
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            widget.onSeekingChanged(false);
                            widget.onLastSeekTimeChanged(null);
                            widget.onLastSeekedProgressChanged(null);
                          }
                        });
                      } else {
                        widget.onSeekingChanged(false);
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
