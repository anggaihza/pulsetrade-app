// lib/features/wallet/presentation/providers/wallet_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WalletTab { broker, cash }

class WalletTabController extends Notifier<WalletTab> {
  @override
  WalletTab build() => WalletTab.broker;

  void setTab(WalletTab tab) => state = tab;
}

final walletTabProvider = NotifierProvider<WalletTabController, WalletTab>(
  WalletTabController.new,
);
