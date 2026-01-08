import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';

/// Video player widget for stock feed
class StockVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;
  final ValueChanged<double>? onProgressUpdate;
  final ValueChanged<VideoPlayerController?>? onControllerReady;

  const StockVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isPlaying = true,
    this.onProgressUpdate,
    this.onControllerReady,
  });

  @override
  State<StockVideoPlayer> createState() => _StockVideoPlayerState();
}

class _StockVideoPlayerState extends State<StockVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final uri = Uri.tryParse(widget.videoUrl);

      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        _controller = VideoPlayerController.networkUrl(uri)
          ..setLooping(true)
          ..addListener(_videoListener);
      } else {
        final assetPath = widget.videoUrl.startsWith('assets/')
            ? widget.videoUrl
            : 'assets/${widget.videoUrl}';
        _controller = VideoPlayerController.asset(assetPath)
          ..setLooping(true)
          ..addListener(_videoListener);
      }

      await _controller!.initialize();
      if (mounted) {
        _controller!.removeListener(_videoListener);
        _controller!.addListener(_videoListener);

        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        if (widget.onControllerReady != null) {
          widget.onControllerReady!(_controller);
        }
        if (widget.isPlaying) {
          _controller!.play();
        }
        if (widget.onProgressUpdate != null &&
            _controller!.value.duration.inMilliseconds > 0) {
          final position = _controller!.value.position.inMilliseconds;
          final duration = _controller!.value.duration.inMilliseconds;
          final progress = (position / duration).clamp(0.0, 1.0);
          widget.onProgressUpdate!(progress);
        }
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        widget.onProgressUpdate != null) {
      final duration = _controller!.value.duration;
      final position = _controller!.value.position;

      // Check if duration is valid
      if (duration.inMilliseconds > 0) {
        final progress = (position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0);
        widget.onProgressUpdate!(progress);
      }
    }
  }

  @override
  void didUpdateWidget(StockVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      // Video URL changed, reinitialize
      _controller?.removeListener(_videoListener);
      _controller?.dispose();
      _initializeVideo();
    } else if (widget.isPlaying != oldWidget.isPlaying && _controller != null) {
      // Defer pause/play to avoid triggering listener during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller != null) {
          if (widget.isPlaying) {
            _controller!.play();
          } else {
            _controller!.pause();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // Notify parent that controller is being disposed
    if (widget.onControllerReady != null) {
      widget.onControllerReady!(null);
    }
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'Video unavailable',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Using placeholder background',
                style: TextStyle(color: AppColors.textLabel, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        });
      },
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }
}

/// Video progress bar with drag-to-seek functionality
class VideoProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final ValueChanged<double>? onSeek;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const VideoProgressBar({
    super.key,
    required this.progress,
    this.onSeek,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isDragging = false;
  double _dragProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    // Use drag progress when dragging, otherwise use widget progress
    final displayProgress = _isDragging ? _dragProgress : widget.progress;
    final clamped = displayProgress.clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) {
        if (widget.onSeek == null) return;
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final width = renderBox.size.width;
        final localPosition = details.localPosition.dx;
        final progress = (localPosition / width).clamp(0.0, 1.0);
        setState(() {
          _isDragging = true;
          _dragProgress = progress;
        });
        widget.onDragStart?.call();
      },
      onHorizontalDragUpdate: (details) {
        if (widget.onSeek == null) return;
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final width = renderBox.size.width;
        final localPosition = details.localPosition.dx;
        final progress = (localPosition / width).clamp(0.0, 1.0);
        setState(() {
          _dragProgress = progress;
        });
      },
      onHorizontalDragEnd: (details) {
        if (widget.onSeek != null && _isDragging) {
          widget.onSeek!(_dragProgress);
        }
        setState(() {
          _isDragging = false;
        });
        widget.onDragEnd?.call();
      },
      onHorizontalDragCancel: () {
        setState(() {
          _isDragging = false;
        });
        widget.onDragEnd?.call();
      },
      onTapDown: (details) {
        if (widget.onSeek == null || _isDragging) return;
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final width = renderBox.size.width;
        final localPosition = details.localPosition.dx;
        final progress = (localPosition / width).clamp(0.0, 1.0);
        widget.onSeek!(progress);
      },
      child: SizedBox(
        height: 10,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final trackHeight = 2.0;
            const thumbSize = 10.0;
            final width = constraints.maxWidth;
            final trackY = (10 - trackHeight) / 2;
            final thumbX = (width - thumbSize) * clamped;
            final filledWidth = thumbX + thumbSize / 2;

            return Stack(
              children: [
                // Background track (grey)
                Positioned(
                  left: 0,
                  right: 0,
                  top: trackY,
                  child: Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFAEAEAE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Filled portion (white)
                Positioned(
                  left: 0,
                  top: trackY,
                  width: filledWidth.clamp(0.0, width),
                  child: Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Thumb indicator
                Positioned(
                  left: thumbX,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
