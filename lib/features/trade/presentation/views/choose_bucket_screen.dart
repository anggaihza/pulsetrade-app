import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';
import 'package:pulsetrade_app/features/trade/presentation/widgets/bucket_donut_chart.dart';

class ChooseBucketScreen extends StatelessWidget {
  const ChooseBucketScreen({super.key});

  static const String routePath = '/choose-bucket';
  static const String routeName = 'choose-bucket';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_narrow_left,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          l10n.chooseBucket,
          style: AppTextStyles.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 20),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // First row of buckets
              Row(
                children: [
                  Expanded(
                    child: _BucketCard(
                      name: l10n.financialBucket,
                      priceChange: 0.50,
                      priceChangePercent: 2.5,
                      isPositive: true,
                      isPublic: true,
                      bookmarksCount: 12,
                      checkmarksCount: 24,
                      avatarColor: const Color(0xFFFFC2B8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BucketCard(
                      name: l10n.technologyBucket,
                      priceChange: 0.50,
                      priceChangePercent: -2.5,
                      isPositive: false,
                      isPublic: false,
                      avatarColor: const Color(0xFFDAD0FC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Second row of buckets
              Row(
                children: [
                  Expanded(
                    child: _BucketCard(
                      name: l10n.financialBucket,
                      priceChange: 0.50,
                      priceChangePercent: 2.5,
                      isPositive: true,
                      isPublic: true,
                      bookmarksCount: 12,
                      checkmarksCount: 24,
                      avatarColor: const Color(0xFFFFC2B8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BucketCard(
                      name: l10n.tourismBucket,
                      priceChange: 0.50,
                      priceChangePercent: -2.5,
                      isPositive: false,
                      isPublic: false,
                      avatarColor: const Color(0xFFFFD4B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BucketCard extends StatelessWidget {
  final String name;
  final double priceChange;
  final double priceChangePercent;
  final bool isPositive;
  final bool isPublic;
  final int? bookmarksCount;
  final int? checkmarksCount;
  final Color avatarColor;

  const _BucketCard({
    required this.name,
    required this.priceChange,
    required this.priceChangePercent,
    required this.isPositive,
    required this.isPublic,
    this.bookmarksCount,
    this.checkmarksCount,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        // TODO: Handle bucket selection
        context.pop();
      },
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
              avatarColor: avatarColor,
            ),
            const SizedBox(height: 8),
            // Price change badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive ? AppColors.successDarker : AppColors.errorDarker,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? TablerIcons.arrow_up : TablerIcons.arrow_down,
                    size: 8,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${priceChange.toStringAsFixed(2)} (${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(1)}%)',
                    style: AppTextStyles.labelSmall(
                      color: isPositive ? AppColors.success : AppColors.error,
                    ).copyWith(fontSize: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Bucket name (split into two lines)
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.split(' ')[0], // First word (e.g., "Financial")
                    style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
                  ),
                  Text(
                    name.split(' ').skip(1).join(' '), // Rest (e.g., "Bucket")
                    style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Status and stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Public/Private indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPublic ? TablerIcons.world : TablerIcons.lock,
                      size: 16,
                      color: AppColors.textLabel,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPublic ? l10n.public : l10n.private,
                      style: AppTextStyles.bodySmall(color: AppColors.textLabel),
                    ),
                  ],
                ),
                // Stats (only show if public)
                if (isPublic && bookmarksCount != null && checkmarksCount != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TablerIcons.bookmarks,
                            size: 14,
                            color: AppColors.textLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bookmarksCount.toString(),
                            style: AppTextStyles.bodySmall(color: AppColors.textLabel),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TablerIcons.check,
                            size: 14,
                            color: AppColors.textLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            checkmarksCount.toString(),
                            style: AppTextStyles.bodySmall(color: AppColors.textLabel),
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

