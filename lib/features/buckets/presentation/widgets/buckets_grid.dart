import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/buckets/domain/models/bucket.dart';
import 'package:pulsetrade_app/features/buckets/presentation/providers/buckets_provider.dart';
import 'package:pulsetrade_app/features/buckets/presentation/widgets/bucket_card.dart';

/// Buckets grid widget displaying buckets in a 2-column grid
/// 
/// Handles loading, error, and empty states.
/// Follows clean architecture:
/// - Uses provider for data fetching
/// - Delegates rendering to BucketCard
/// - Handles all async states properly
class BucketsGrid extends ConsumerWidget {
  const BucketsGrid({
    super.key,
    this.onBucketTap,
    this.ticker,
  });

  /// Optional stock ticker to filter buckets
  final String? ticker;

  /// Callback when a bucket is tapped
  final void Function(Bucket bucket)? onBucketTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use bucketsForStockProvider if ticker is provided, otherwise use bucketsProvider
    final bucketsAsync = ticker != null
        ? ref.watch(bucketsForStockProvider(ticker!))
        : ref.watch(bucketsProvider);

    return bucketsAsync.when(
      data: (buckets) {
        if (buckets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No buckets available',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        // Build 2-column grid
        return _buildGrid(buckets);
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
            'Error loading buckets: $error',
            style: AppTextStyles.bodyMedium(
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<Bucket> buckets) {
    // Group buckets into rows of 2
    final rows = <List<Bucket>>[];
    for (int i = 0; i < buckets.length; i += 2) {
      if (i + 1 < buckets.length) {
        rows.add([buckets[i], buckets[i + 1]]);
      } else {
        rows.add([buckets[i]]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: rows.indexOf(row) < rows.length - 1 ? 16 : 0,
          ),
          child: Row(
            children: [
              Expanded(
                child: BucketCard(
                  bucket: row[0],
                  onTap: onBucketTap != null ? () => onBucketTap!(row[0]) : null,
                ),
              ),
              if (row.length > 1) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: BucketCard(
                    bucket: row[1],
                    onTap: onBucketTap != null ? () => onBucketTap!(row[1]) : null,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

