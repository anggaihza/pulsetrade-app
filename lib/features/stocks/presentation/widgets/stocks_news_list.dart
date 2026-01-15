import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/stocks/presentation/providers/stocks_news_provider.dart';
import 'package:pulsetrade_app/features/stocks/presentation/widgets/stocks_news_list_item.dart';

/// News list widget for stocks overview screen
/// 
/// Displays a list of news items for a specific stock ticker.
/// Handles loading, error, and empty states.
/// 
/// Follows clean architecture:
/// - Uses provider for data fetching
/// - Delegates rendering to StocksNewsListItem
/// - Handles all async states properly
class StocksNewsList extends ConsumerWidget {
  const StocksNewsList({
    super.key,
    required this.ticker,
    this.onNewsItemTap,
  });

  final String ticker;
  final void Function(String newsId)? onNewsItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(stocksNewsProvider(ticker));

    return newsAsync.when(
      data: (newsItems) {
        if (newsItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No news available',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: newsItems.map((newsItem) {
            return StocksNewsListItem(
              newsItem: newsItem,
              onTap: onNewsItemTap != null
                  ? () => onNewsItemTap!(newsItem.id)
                  : null,
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error loading news: $error',
            style: AppTextStyles.bodyMedium(
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}

