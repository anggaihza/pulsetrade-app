import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/buckets/presentation/widgets/buckets_grid.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class ChooseBucketScreen extends ConsumerWidget {
  const ChooseBucketScreen({super.key});

  static const String routePath = '/choose-bucket';
  static const String routeName = 'choose-bucket';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          style: AppTextStyles.titleSmall(
            color: AppColors.textPrimary,
          ).copyWith(fontSize: 20),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: BucketsGrid(
            onBucketTap: (bucket) {
              // TODO: Handle bucket selection
              context.pop();
            },
          ),
        ),
      ),
    );
  }
}
