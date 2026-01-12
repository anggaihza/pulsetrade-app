import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/core/storage/preferences/preferences_storage.dart';
import 'package:pulsetrade_app/features/profile/presentation/widgets/trading_mode_modal.dart';

class TradingModeNotifier extends Notifier<TradingMode> {
  TradingModeNotifier();

  static const String _tradingModeKey = 'trading_mode';

  @override
  TradingMode build() {
    final storage = ref.read(preferencesStorageProvider);
    final modeString = storage.readString(_tradingModeKey);
    if (modeString != null) {
      return TradingMode.values.firstWhere(
        (mode) => mode.name == modeString,
        orElse: () => TradingMode.lite,
      );
    }
    return TradingMode.lite;
  }

  Future<void> setTradingMode(TradingMode mode) async {
    final storage = ref.read(preferencesStorageProvider);
    await storage.writeString(_tradingModeKey, mode.name);
    state = mode;
  }
}

final tradingModeProvider = NotifierProvider<TradingModeNotifier, TradingMode>(
  TradingModeNotifier.new,
);

