// lib/features/wallet/presentation/providers/deposit_method_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DepositMethod { eWallet, bankTransfer, virtualAccount }

class DepositMethodController extends Notifier<DepositMethod> {
  @override
  DepositMethod build() => DepositMethod.eWallet;

  void setMethod(DepositMethod method) => state = method;
}

final depositMethodProvider =
    NotifierProvider<DepositMethodController, DepositMethod>(
      DepositMethodController.new,
    );
