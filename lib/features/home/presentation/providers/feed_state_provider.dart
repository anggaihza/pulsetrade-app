import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized state for the home feed.
///
/// This is intentionally UI-agnostic and focuses on:
/// - Which feed item is active
/// - Whether the chart is expanded
/// - Per-ticker like / bookmark state
class FeedState {
  final int currentFeedIndex;
  final bool isChartExpanded;
  final Set<String> likedTickers;
  final Set<String> bookmarkedTickers;

  const FeedState({
    this.currentFeedIndex = 0,
    this.isChartExpanded = false,
    this.likedTickers = const {},
    this.bookmarkedTickers = const {},
  });

  FeedState copyWith({
    int? currentFeedIndex,
    bool? isChartExpanded,
    Set<String>? likedTickers,
    Set<String>? bookmarkedTickers,
  }) {
    return FeedState(
      currentFeedIndex: currentFeedIndex ?? this.currentFeedIndex,
      isChartExpanded: isChartExpanded ?? this.isChartExpanded,
      likedTickers: likedTickers ?? this.likedTickers,
      bookmarkedTickers: bookmarkedTickers ?? this.bookmarkedTickers,
    );
  }
}

/// Notifier for managing `FeedState`.
///
/// This is designed to outlive individual widget rebuilds so that
/// feed state persists while the user navigates around the app.
class FeedStateNotifier extends Notifier<FeedState> {
  @override
  FeedState build() => const FeedState();

  /// Set the currently active feed index.
  void setCurrentFeedIndex(int index) {
    state = state.copyWith(currentFeedIndex: index);
  }

  /// Toggle the chart expanded/collapsed state.
  void toggleChartExpanded() {
    state = state.copyWith(isChartExpanded: !state.isChartExpanded);
  }

  /// Explicitly set chart expanded state.
  void setChartExpanded(bool isExpanded) {
    state = state.copyWith(isChartExpanded: isExpanded);
  }

  /// Toggle like for a given ticker.
  void toggleLike(String ticker) {
    final liked = Set<String>.from(state.likedTickers);
    if (liked.contains(ticker)) {
      liked.remove(ticker);
    } else {
      liked.add(ticker);
    }
    state = state.copyWith(likedTickers: liked);
  }

  /// Toggle bookmark for a given ticker.
  void toggleBookmark(String ticker) {
    final bookmarked = Set<String>.from(state.bookmarkedTickers);
    if (bookmarked.contains(ticker)) {
      bookmarked.remove(ticker);
    } else {
      bookmarked.add(ticker);
    }
    state = state.copyWith(bookmarkedTickers: bookmarked);
  }

  bool isLiked(String ticker) => state.likedTickers.contains(ticker);

  bool isBookmarked(String ticker) => state.bookmarkedTickers.contains(ticker);
}

/// Global provider for home feed state.
///
/// Example usage:
/// ```dart
/// final feedState = ref.watch(feedStateProvider);
/// final notifier = ref.read(feedStateProvider.notifier);
/// ```
final feedStateProvider =
    NotifierProvider<FeedStateNotifier, FeedState>(FeedStateNotifier.new);


