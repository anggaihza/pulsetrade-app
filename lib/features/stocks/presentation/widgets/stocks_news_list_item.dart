import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// News list item widget for stocks overview screen
/// 
/// Displays a single news item with:
/// - Timestamp and source (e.g., "5:55 PM • Dec 3 • American News")
/// - Headline (bold, 14px)
/// - Bottom border separator
/// 
/// Follows Figma design specifications:
/// - Padding: 12px vertical, 0px horizontal
/// - Gap: 8px between timestamp and headline
/// - Border: 0.5px solid #2c2c2c at bottom
class StocksNewsListItem extends StatelessWidget {
  const StocksNewsListItem({
    super.key,
    required this.newsItem,
    this.onTap,
  });

  final NewsItem newsItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.surface,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timestamp and source
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
      ),
    );
  }
}

