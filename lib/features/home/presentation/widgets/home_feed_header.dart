import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/feed_state_provider.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/video_controller_provider.dart';
import 'package:pulsetrade_app/features/profile/presentation/views/profile_screen.dart';

/// Floating header widget for the home feed with search and profile buttons.
class HomeFeedHeader extends ConsumerStatefulWidget {
  final bool isPageActive;
  final ValueChanged<bool> onPageActiveChanged;

  const HomeFeedHeader({
    super.key,
    required this.isPageActive,
    required this.onPageActiveChanged,
  });

  @override
  ConsumerState<HomeFeedHeader> createState() => _HomeFeedHeaderState();
}

class _HomeFeedHeaderState extends ConsumerState<HomeFeedHeader> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Search button
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  TablerIcons.search,
                  size: 24,
                  color: AppColors.background,
                ),
              ),
              const SizedBox(width: 8),

              // Profile button
              GestureDetector(
                onTap: () async {
                  final currentIndex = ref
                      .read(feedStateProvider)
                      .currentFeedIndex;
                  final registry = ref.read(videoControllerProvider);
                  // Pause video while navigating away from home
                  final controller = registry.controllerForIndex(
                    currentIndex,
                  );
                  controller?.pause();
                  widget.onPageActiveChanged(false);

                  await context.push(ProfileScreen.routePath);

                  if (!mounted) return;

                  // Resume video when coming back to home
                  widget.onPageActiveChanged(true);
                  final currentController = registry.controllerForIndex(
                    currentIndex,
                  );
                  if (currentController != null &&
                      currentController.value.isInitialized) {
                    currentController.play();
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    TablerIcons.user,
                    size: 24,
                    color: AppColors.whiteNormal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

