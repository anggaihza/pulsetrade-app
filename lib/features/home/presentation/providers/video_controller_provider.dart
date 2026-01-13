import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// Registry object that owns and manages video controllers for the home feed.
///
/// This keeps the controller lifecycle separate from widgets while allowing
/// Riverpod to dispose everything automatically.
class VideoControllerRegistry {
  final Map<int, VideoPlayerController> _controllers = {};

  /// Get the controller for a given feed index.
  VideoPlayerController? controllerForIndex(int index) => _controllers[index];

  /// Register (or replace) a controller for a given index.
  ///
  /// If a controller already exists for that index, it will be disposed
  /// before being replaced.
  void setController(int index, VideoPlayerController controller) {
    final existing = _controllers[index];
    if (existing != null && existing != controller) {
      existing.dispose();
    }
    _controllers[index] = controller;
  }

  /// Remove the controller for a given index and dispose it.
  void removeController(int index) {
    final existing = _controllers.remove(index);
    existing?.dispose();
  }

  /// Remove all controllers whose index does not satisfy the predicate.
  ///
  /// Useful for cleaning up controllers that are far from the current index,
  /// e.g., keep only current ± 1.
  void retainWhere(bool Function(int index) test) {
    final toRemove = <int>[];
    _controllers.forEach((index, controller) {
      if (!test(index)) {
        controller.dispose();
        toRemove.add(index);
      }
    });
    for (final index in toRemove) {
      _controllers.remove(index);
    }
  }

  /// Dispose all controllers.
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

/// Provider for centralized video controller management in the home feed.
///
/// Example usage:
/// ```dart
/// final registry = ref.read(videoControllerProvider);
/// registry.setController(index, controller);
/// final controller = registry.controllerForIndex(index);
/// ```
final videoControllerProvider = Provider<VideoControllerRegistry>((ref) {
  final registry = VideoControllerRegistry();
  ref.onDispose(registry.disposeAll);
  return registry;
});


