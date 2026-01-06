# Home Feed Setup Guide

## Quick Start

The home feed has been fully implemented! Here's how to use it:

### 1. Navigate to Home Feed

The screen is available at `/feed` route:

```dart
context.go(HomeFeedScreen.routePath); // Navigate from anywhere
```

Or update your router's initial location:
```dart
initialLocation: HomeFeedScreen.routePath,
```

### 2. Add Video Assets

The video player currently expects videos at:
```
assets/videos/stock_video.mp4
```

**For testing**, you can:
1. Add any MP4 video to `assets/videos/`
2. Or update `video_player_widget.dart` to use network URLs:

```dart
_controller = VideoPlayerController.networkUrl(
  Uri.parse(widget.videoUrl),
);
```

### 3. Mock Data vs. Real Data

Currently using mock data in `home_feed_screen.dart`:
```dart
void _initializeMockData() {
  // Generate mock chart data
  _chartDataList = [/* ... */];
  _stockFeed = [/* ... */];
  _commentsList = [/* ... */];
}
```

**For production:**
1. Create providers/repositories for stock data
2. Replace mock data with API calls
3. Implement infinite scroll with `PageView.builder`

## Features Implemented

✅ **Video Background**
- Full-screen video player
- Auto-loop
- Tap to play/pause
- Progress bar indicator

✅ **Stock Info Card**
- Ticker symbol
- Current price + change
- Sentiment bar (Bullish/Bearish)
- Glassmorphic design

✅ **Interactive Chart**
- Expandable/collapsible (80px ↔ 300px)
- Touch-based crosshair tooltip
- Timeline with dates
- Price axis labels
- Smooth animations

✅ **Description Section**
- News title
- Truncated description
- "More/Less" toggle
- Collapses chart when expanded

✅ **Interaction Sidebar**
- Like (heart icon, fillable)
- Comment (opens bottom sheet)
- Bookmark (fillable)
- Share
- Formatted counts (1.2K, 1.5M)

✅ **Comments Bottom Sheet**
- Comment list
- User avatars
- Like comments
- Reply threads
- Emoji quick-reactions
- Add comment input

✅ **Bottom Navigation**
- 5 tabs: Home, Portfolio, Discover, Watchlist, Wallet
- Active state with pill background
- Tabler Icons

✅ **Swipe Gestures**
- Swipe right → Show chart
- Swipe left → Buy action
- Visual indicators during swipe
- First-use hint overlay

✅ **Fully Localized**
- English & Spanish
- All strings in ARB files

## Components Created

```
lib/features/home/
├── domain/models/
│   └── stock_data.dart
├── presentation/
│   ├── views/
│   │   ├── home_screen.dart (existing)
│   │   └── home_feed_screen.dart (✨ NEW)
│   └── widgets/
│       ├── stock_info_card.dart (✨ NEW)
│       ├── stock_chart_widget.dart (✨ NEW)
│       ├── stock_description.dart (✨ NEW)
│       ├── interaction_sidebar.dart (✨ NEW)
│       ├── bottom_navigation_bar.dart (✨ NEW)
│       ├── comments_bottom_sheet.dart (✨ NEW)
│       ├── video_player_widget.dart (✨ NEW)
│       └── swipeable_feed_item.dart (✨ NEW)
```

## Dependencies Added

```yaml
video_player: ^2.9.2
fl_chart: ^0.69.2
```

## Next Steps

### Immediate
1. **Add test video:** Place an MP4 in `assets/videos/stock_video.mp4`
2. **Test the feed:** Run the app and navigate to `/feed`

### Production-Ready
1. **Vertical Scrolling:**
   ```dart
   PageView.builder(
     scrollDirection: Axis.vertical,
     itemCount: stockFeed.length,
     onPageChanged: (index) => loadMoreIfNeeded(index),
     itemBuilder: (context, index) => FeedItem(stock: stockFeed[index]),
   )
   ```

2. **Real-time Data:**
   - WebSocket for live prices
   - Chart auto-refresh
   - Real-time comment updates

3. **Video Streaming:**
   - Network video URLs
   - Video preloading (next/prev)
   - Adaptive bitrate

4. **State Management:**
   - Create Riverpod providers
   - Repository pattern for data
   - Cache management

5. **Performance:**
   - Video memory limits
   - Chart rendering optimization
   - List virtualization

## Testing the Implementation

Run these checks:

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate localizations
flutter gen-l10n

# 3. Run the app
flutter run
```

**Manual Test Checklist:**
- [ ] Video plays automatically
- [ ] Chart expands/collapses on tap
- [ ] "More" button works and collapses chart
- [ ] Like/bookmark toggle states
- [ ] Comments sheet opens
- [ ] Bottom nav highlights active tab
- [ ] Swipe gestures show indicators
- [ ] Progress bar updates
- [ ] All text shows correctly

## Known Limitations

1. **Placeholder Video:** Need actual video asset or network URL
2. **Mock Data:** Replace with real API integration
3. **Single Feed Item:** Implement vertical scrolling for multiple stocks
4. **Share Function:** Not yet implemented (needs platform-specific package)

## Architecture Notes

- **Clean Architecture:** Domain models, presentation layer separation
- **Component Reusability:** All widgets are self-contained
- **Design System:** Uses global `AppColors`, `AppTextStyles`, `AppSpacing`
- **Localization:** Full i18n support via `gen-l10n`
- **Type Safety:** Strong typing throughout

## Support

See full documentation: `docs/features/home-feed.md`

