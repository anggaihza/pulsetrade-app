import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// Sidebar with interaction buttons (like, comment, bookmark, share)
class InteractionSidebar extends StatelessWidget {
  final StockStats stats;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final bool isLiked;
  final bool isBookmarked;

  const InteractionSidebar({
    super.key,
    required this.stats,
    this.onLike,
    this.onComment,
    this.onBookmark,
    this.onShare,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button
        _InteractionButton(
          icon: isLiked ? TablerIcons.heart_filled : TablerIcons.heart,
          count: _formatCount(stats.likes),
          onTap: onLike,
          isActive: isLiked,
        ),
        const SizedBox(height: 12),

        // Comment button
        _InteractionButton(
          icon: TablerIcons.message_filled,
          count: _formatCount(stats.comments),
          onTap: onComment,
        ),
        const SizedBox(height: 12),

        // Bookmark button
        _InteractionButton(
          icon: isBookmarked
              ? TablerIcons.bookmarks_filled
              : TablerIcons.bookmarks_filled,
          count: _formatCount(stats.bookmarks),
          onTap: onBookmark,
          isActive: isBookmarked,
        ),
        const SizedBox(height: 12),

        // Share button
        _InteractionButton(
          icon: TablerIcons.share_3,
          count: _formatCount(stats.shares),
          onTap: onShare,
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String count;
  final VoidCallback? onTap;
  final bool isActive;

  const _InteractionButton({
    required this.icon,
    required this.count,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: isActive ? AppColors.primary : AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppTextStyles.labelSmall(
              color: AppColors.textPrimary,
            ).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
