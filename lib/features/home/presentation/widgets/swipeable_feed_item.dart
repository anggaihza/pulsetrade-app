import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Swipeable wrapper for feed items with gesture hints
class SwipeableFeedItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeRight; // For chart
  final VoidCallback? onSwipeLeft; // For buy
  final bool showHint;

  const SwipeableFeedItem({
    super.key,
    required this.child,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.showHint = false,
  });

  @override
  State<SwipeableFeedItem> createState() => _SwipeableFeedItemState();
}

class _SwipeableFeedItemState extends State<SwipeableFeedItem>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isDragging = false;
  static const double _swipeThreshold = 100.0;
  static const double _maxDragDistance = 150.0;

  late AnimationController _hintController;
  late Animation<double> _hintAnimation;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _hintAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    if (widget.showHint) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _hintController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragPosition += details.primaryDelta!;
      _dragPosition = _dragPosition.clamp(-_maxDragDistance, _maxDragDistance);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    if (_dragPosition > _swipeThreshold) {
      // Swipe right - show chart
      widget.onSwipeRight?.call();
    } else if (_dragPosition < -_swipeThreshold) {
      // Swipe left - buy action
      widget.onSwipeLeft?.call();
    }

    setState(() {
      _dragPosition = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Main content
          Transform.translate(
            offset: Offset(_dragPosition * 0.3, 0),
            child: widget.child,
          ),
          
          // Left side indicator (Buy)
          if (_isDragging && _dragPosition < 0)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'BUY',
                    style: AppTextStyles.labelLarge(
                      color: AppColors.textPrimary,
                    ).copyWith(fontSize: 16),
                  ),
                ),
              ),
            ),
          
          // Right side indicator (Chart)
          if (_isDragging && _dragPosition > 0)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CHART',
                    style: AppTextStyles.labelLarge(
                      color: AppColors.textPrimary,
                    ).copyWith(fontSize: 16),
                  ),
                ),
              ),
            ),
          
          // Gesture hint overlay (shown on first use)
          if (widget.showHint)
            AnimatedBuilder(
              animation: _hintAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: 0.7 * (1 - _hintAnimation.value),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Swipe gesture icon
                          Icon(
                            Icons.swipe,
                            size: 64,
                            color: AppColors.textPrimary.withValues(
                              alpha: 1 - _hintAnimation.value * 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Instructions
                          Text(
                            'Swipe right for charts',
                            style: AppTextStyles.labelLarge(
                              color: AppColors.textPrimary,
                            ).copyWith(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Swipe left to buy',
                            style: AppTextStyles.labelLarge(
                              color: AppColors.textPrimary,
                            ).copyWith(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

