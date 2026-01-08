import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// Bottom sheet for displaying news list
class NewsBottomSheet extends StatelessWidget {
  final List<NewsItem> newsItems;

  const NewsBottomSheet({
    super.key,
    required this.newsItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 74,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.textLabel,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),

          // Content section with padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Latest News',
                    style: AppTextStyles.titleSmall(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // News list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: newsItems.length,
                      itemBuilder: (context, index) {
                        final newsItem = newsItems[index];
                        final isLast = index == newsItems.length - 1;
                        return _NewsItemWidget(
                          newsItem: newsItem,
                          showBorder: !isLast,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual news item widget
class _NewsItemWidget extends StatelessWidget {
  final NewsItem newsItem;
  final bool showBorder;

  const _NewsItemWidget({
    required this.newsItem,
    required this.showBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.surface,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            newsItem.timestamp,
            style: AppTextStyles.bodySmall(
              color: AppColors.textLabel,
            ),
          ),
          const SizedBox(height: 8),
          // Headline
          Text(
            newsItem.headline,
            style: AppTextStyles.labelLarge(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Show news bottom sheet
void showNewsSheet(
  BuildContext context,
  List<NewsItem> newsItems,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: NewsBottomSheet(
          newsItems: newsItems,
        ),
      );
    },
  );
}

