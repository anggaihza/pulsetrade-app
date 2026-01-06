# Home Feed - Trading Video Feed

## Overview

The Home Feed is a TikTok-style vertical scrolling feed that combines video content with stock market information. Users can view stock news videos, interact with content, view charts, and execute trades through an intuitive swipe-based interface.

## Design Reference

**Figma Designs:**
- [Default Feed View](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=10-2794&m=dev)
- [Expanded Chart View](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=10-2930&m=dev)
- [Comments Section](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=10-2832&m=dev)
- [Gesture Hint](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=10-3043&m=dev)
- [Chart Tooltip](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=10-8968&m=dev)
- [Chart Collapsed](https://www.figma.com/design/33pzR0AFb7Hz3R11vuYtwW/Untitled?node-id=10-8921&m=dev)

## Architecture

### File Structure

```
lib/features/home/
├── domain/
│   └── models/
│       └── stock_data.dart           # Data models
├── presentation/
│   ├── views/
│   │   ├── home_screen.dart          # Original simple home
│   │   └── home_feed_screen.dart     # New trading feed
│   └── widgets/
│       ├── stock_info_card.dart      # Ticker, price, sentiment
│       ├── stock_chart_widget.dart   # Expandable chart
│       ├── stock_description.dart    # News with "more" toggle
│       ├── interaction_sidebar.dart  # Like, comment, bookmark, share
│       ├── bottom_navigation_bar.dart # 5-tab navigation
│       ├── comments_bottom_sheet.dart # Comments modal
│       ├── video_player_widget.dart  # Video background
│       └── swipeable_feed_item.dart  # Gesture wrapper
```

## Components

### 1. Stock Info Card

**File:** `stock_info_card.dart`

Displays core stock information in a glassmorphic card:
- **Ticker Symbol** (e.g., TSLA)
- **Current Price** with change indicator
- **Sentiment Bar** (Bullish/Bearish visual indicator)

**Usage:**
```dart
StockInfoCard(
  stock: stockData,
)
```

**Design:**
- Background: `AppColors.background` with 50% opacity
- Border radius: 12px
- Padding: 16px
- Sentiment bar uses success (green) and error (red) colors

---

### 2. Stock Chart Widget

**File:** `stock_chart_widget.dart`

Interactive chart with expand/collapse functionality:
- **Collapsed State:** 80px mini preview
- **Expanded State:** 300px full chart with timeline
- **Crosshair Tooltip:** Shows price on touch
- **fl_chart Library:** Used for chart rendering

**Usage:**
```dart
StockChartWidget(
  ticker: 'TSLA',
  currentPrice: 177.12,
  changePercentage: -1.28,
  chartData: chartDataPoints,
  isExpanded: isChartExpanded,
  onToggleExpand: () => setState(() => isChartExpanded = !isChartExpanded),
)
```

**Features:**
- Area chart with gradient fill
- Y-axis labels on the right
- X-axis shows dates
- Touch-based tooltip with yellow indicator

---

### 3. Stock Description

**File:** `stock_description.dart`

News description with expandable content:
- **Title:** Bold 14px
- **Description:** Truncated at 100 characters
- **"More/Less" Toggle:** Expands/collapses content
- **Date:** Secondary text color

**Usage:**
```dart
StockDescription(
  title: 'News Title',
  description: 'Full description text...',
  date: '19 Aug 2025',
  onMoreToggle: () {
    // Collapse chart when description expands
  },
)
```

**Behavior:**
- When "more" is clicked, chart collapses (if expanded)
- Preserves UX by managing content visibility

---

### 4. Interaction Sidebar

**File:** `interaction_sidebar.dart`

Vertical stack of interaction buttons:
- **Like (Heart):** Filled when liked
- **Comment (Message):** Opens comments sheet
- **Bookmark:** Filled when bookmarked
- **Share:** Share functionality

**Usage:**
```dart
InteractionSidebar(
  stats: stock.stats,
  isLiked: isLiked,
  isBookmarked: isBookmarked,
  onLike: () => toggleLike(),
  onComment: () => showComments(),
  onBookmark: () => toggleBookmark(),
  onShare: () => shareContent(),
)
```

**Count Formatting:**
- 1,000+ → "1.0K"
- 1,000,000+ → "1.0M"

---

### 5. Bottom Navigation Bar

**File:** `bottom_navigation_bar.dart`

5-segment navigation:
1. **Home** (house icon)
2. **Portfolio** (chart-donut icon)
3. **Discover** (world icon)
4. **Watchlist** (bookmark icon)
5. **Wallet** (wallet icon)

**Usage:**
```dart
HomeBottomNavigationBar(
  currentIndex: 0,
  onTap: (index) {
    setState(() => currentNavIndex = index);
  },
)
```

**Design:**
- Height: 60px
- Active tab: Blue pill background
- Icons from `flutter_tabler_icons`

---

### 6. Comments Bottom Sheet

**File:** `comments_bottom_sheet.dart`

Modal bottom sheet for comments:
- **Header:** Comment count
- **Comment List:** User avatar, name, text, timestamp
- **Emoji Bar:** Quick emoji reactions
- **Input Field:** Add new comments

**Usage:**
```dart
showCommentsSheet(
  context,
  commentsList,
  onAddComment: () => addComment(),
  onLikeComment: (id) => likeComment(id),
);
```

**Features:**
- Draggable handle
- Nested replies (View X Replies)
- Like button per comment
- Emoji shortcuts

---

### 7. Video Player Widget

**File:** `video_player_widget.dart`

Full-screen video background:
- **video_player Package:** Official Flutter package
- **Auto-loop:** Videos repeat continuously
- **Progress Bar:** Bottom indicator with scrubber dot

**Usage:**
```dart
StockVideoPlayer(
  videoUrl: 'assets/videos/stock_video.mp4',
  onProgressUpdate: (progress) {
    setState(() => videoProgress = progress);
  },
)
```

**Video Progress Bar:**
```dart
VideoProgressBar(progress: 0.65) // 65% complete
```

---

### 8. Swipeable Feed Item

**File:** `swipeable_feed_item.dart`

Gesture wrapper for swipe actions:
- **Swipe Right → Show Chart** (blue "CHART" indicator)
- **Swipe Left → Buy Action** (green "BUY" indicator)
- **First-Use Hint:** Animated overlay with instructions

**Usage:**
```dart
SwipeableFeedItem(
  showHint: isFirstTime,
  onSwipeRight: () => setState(() => isChartExpanded = true),
  onSwipeLeft: () => showBuyDialog(),
  child: contentWidget,
)
```

**Gesture Thresholds:**
- Activation: 100px drag
- Max drag: 150px

---

## Main Screen

**File:** `home_feed_screen.dart`

Orchestrates all components:

### Layout Hierarchy

```
Stack
├── Video Background (Full screen)
└── SafeArea
    └── Column
        ├── Header (Search + Profile buttons)
        ├── Expanded (Main content)
        │   └── Row
        │       ├── Expanded (Left side)
        │       │   ├── Stock Info Card
        │       │   ├── Chart Widget
        │       │   └── Description
        │       └── Interaction Sidebar (Right side)
        └── Video Progress Bar
        
BottomNavigationBar (Outside Column)
```

### State Management

```dart
int _currentNavIndex = 0;
int _currentFeedIndex = 0;
bool _isChartExpanded = false;
bool _isLiked = false;
bool _isBookmarked = false;
double _videoProgress = 0.0;
```

### Key Interactions

1. **Chart Toggle:**
   ```dart
   void _toggleChart() {
     setState(() {
       _isChartExpanded = !_isChartExpanded;
     });
   }
   ```

2. **Description "More" Toggle:**
   ```dart
   void _onDescriptionMoreToggle() {
     if (_isChartExpanded) {
       setState(() {
         _isChartExpanded = false;
       });
     }
   }
   ```

3. **Show Comments:**
   ```dart
   void _showComments() {
     showCommentsSheet(context, _currentComments);
   }
   ```

---

## Data Models

**File:** `stock_data.dart`

### StockData
```dart
class StockData {
  final String ticker;
  final double price;
  final double change;
  final double changePercentage;
  final bool isPositive;
  final String sentiment;
  final double sentimentScore; // 0.0 to 1.0
  final String newsTitle;
  final String newsDescription;
  final String date;
  final String videoUrl;
  final String? thumbnailUrl;
  final StockStats stats;
}
```

### StockStats
```dart
class StockStats {
  final int likes;
  final int comments;
  final int bookmarks;
  final int shares;
}
```

### ChartDataPoint
```dart
class ChartDataPoint {
  final DateTime date;
  final double value;
}
```

### CommentData
```dart
class CommentData {
  final String id;
  final String userName;
  final String userAvatar;
  final String comment;
  final String timestamp;
  final int likes;
  final int replies;
  final bool isLiked;
}
```

---

## Localization

All user-facing text is localized. See `app_en.arb` / `app_es.arb`:

```dart
strings.home
strings.portfolio
strings.discover
strings.watchlist
strings.wallet
strings.bullish
strings.bearish
strings.neutral
strings.more
strings.less
strings.comments
strings.addComment
strings.reply
strings.swipeRightForCharts
strings.swipeLeftToBuy
strings.buy
strings.chart
```

---

## Dependencies

```yaml
video_player: ^2.9.2       # Video playback
fl_chart: ^0.69.2          # Interactive charts
flutter_tabler_icons: ^1.28.0  # Icon set
```

---

## Assets Required

### Videos
```
assets/videos/stock_video.mp4  # Placeholder video for feed
```

Add to `pubspec.yaml`:
```yaml
assets:
  - assets/videos/
```

---

## Future Enhancements

1. **Vertical Scrolling:**
   - Implement `PageView` for swipe up/down between stocks
   - Preload next/previous videos

2. **Real-time Data:**
   - WebSocket connection for live price updates
   - Chart auto-refresh

3. **Video Streaming:**
   - Network video URLs instead of assets
   - Adaptive bitrate streaming

4. **Advanced Gestures:**
   - Double-tap to like (TikTok-style)
   - Long-press for more options

5. **Personalization:**
   - ML-based feed recommendations
   - User preferences for stock categories

---

## Testing Checklist

- [ ] Video plays automatically
- [ ] Chart expands/collapses on tap
- [ ] "More" button collapses chart
- [ ] Swipe right shows chart
- [ ] Swipe left triggers buy action
- [ ] Comments sheet opens with correct data
- [ ] Like/bookmark states persist
- [ ] Bottom navigation switches tabs
- [ ] Progress bar updates during video playback
- [ ] All interactions work with gestures
- [ ] Localization strings display correctly
- [ ] Layout responds to different screen sizes

---

## Performance Considerations

1. **Video Memory:**
   - Dispose `VideoPlayerController` properly
   - Limit preloaded videos to 3 max

2. **Chart Rendering:**
   - Use `RepaintBoundary` for chart widget
   - Throttle touch events to 60fps

3. **List Performance:**
   - Use `PageView.builder` for infinite scroll
   - Lazy-load chart data

4. **Image Optimization:**
   - Cache user avatars
   - Use `CachedNetworkImage` for remote images

---

## Known Issues

1. **Video Asset Placeholder:**
   - Current implementation uses a placeholder asset path
   - Replace with actual video or network URL in production

2. **Comment Replies:**
   - Reply functionality UI exists but not fully implemented
   - Needs backend integration

3. **Share Functionality:**
   - Share button exists but action not implemented
   - Requires platform-specific sharing package

---

## Related Documentation

- [Design System](../design-system.md)
- [Components Overview](../components/overview.md)
- [Architecture](../architecture.md)

