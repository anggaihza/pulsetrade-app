import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/storage/preferences/preferences_storage.dart';

/// Key for storing whether the gesture hint has been shown
const String _gestureHintShownKey = 'gesture_hint_shown';

/// Provider that tracks whether the gesture hint has been shown to the user.
///
/// Uses SharedPreferences to persist the state across app sessions.
final gestureHintShownProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(preferencesStorageProvider);
  return storage.readBool(_gestureHintShownKey) ?? false;
});

/// Provider for the notifier that can mark the hint as shown.
final gestureHintNotifierProvider =
    Provider<GestureHintNotifier>((ref) => GestureHintNotifier(ref));

class GestureHintNotifier {
  final Ref _ref;

  GestureHintNotifier(this._ref);

  /// Mark the gesture hint as shown and save to preferences.
  Future<void> markAsShown() async {
    final storage = _ref.read(preferencesStorageProvider);
    await storage.writeBool(_gestureHintShownKey, true);
    _ref.invalidate(gestureHintShownProvider);
  }
}

