import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod/riverpod.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl(ref.read(connectivityProvider)));
