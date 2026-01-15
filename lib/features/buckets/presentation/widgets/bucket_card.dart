import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/buckets/domain/models/bucket.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/bucket_donut_chart.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

/// Global reusable bucket card widget
/// 
/// Displays a single bucket with:
/// - Donut chart with avatar/image
/// - Price change badge (green/red)
/// - Bucket name (2 lines)
/// - Privacy indicator (Public/Private)
/// - Stats (bookmarks, checkmarks) - only for public buckets
/// 
/// Follows Figma design specifications:
/// - Padding: 16px
/// - Border radius: 12px
/// - Shadow: 0px 4px 4px rgba(0,0,0,0.25)
/// - Gap: 8px between elements
class BucketCard extends StatelessWidget {
  const BucketCard({
    super.key,
    required this.bucket,
    this.onTap,
  });

  final Bucket bucket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Donut chart with avatar
            BucketDonutChart(
              size: 100,
              avatarColor: bucket.avatarColor,
              imageAsset: bucket.imageAsset,
            ),
            const SizedBox(height: 8),
            // Price change badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bucket.isPositive
                    ? AppColors.successDarker
                    : AppColors.errorDarker,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    bucket.isPositive
                        ? TablerIcons.caret_up_filled
                        : TablerIcons.caret_down_filled,
                    size: 8,
                    color: bucket.isPositive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${bucket.priceChange.toStringAsFixed(2)} (${bucket.isPositive ? '+' : ''}${bucket.priceChangePercent.toStringAsFixed(1)}%)',
                    style: AppTextStyles.labelSmall(
                      color: bucket.isPositive ? AppColors.success : AppColors.error,
                    ).copyWith(fontSize: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Bucket name (2 lines)
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bucket.name.split(' ')[0],
                    style: AppTextStyles.labelLarge(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    bucket.name.split(' ').skip(1).join(' '),
                    style: AppTextStyles.labelLarge(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Privacy indicator and stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      bucket.isPublic ? TablerIcons.world : TablerIcons.lock,
                      size: 16,
                      color: AppColors.textLabel,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bucket.isPublic ? l10n.public : l10n.private,
                      style: AppTextStyles.bodySmall(
                        color: AppColors.textLabel,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (bucket.isPublic &&
                    bucket.bookmarksCount != null &&
                    bucket.checkmarksCount != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            TablerIcons.bookmarks_filled,
                            size: 14,
                            color: AppColors.textLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bucket.bookmarksCount.toString(),
                            style: AppTextStyles.bodySmall(
                              color: AppColors.textLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            TablerIcons.copy_check_filled,
                            size: 14,
                            color: AppColors.textLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bucket.checkmarksCount.toString(),
                            style: AppTextStyles.bodySmall(
                              color: AppColors.textLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

