import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  // Stream that broadcasts connection changes (online/offline)
  final _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityResult>.broadcast();

  ConnectivityService() {
    // Subscribe to connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _controller.add(result);
    });
  }

  // Expose the stream so we can listen elsewhere
  Stream<ConnectivityResult> get connectivityStream => _controller.stream;

  // Optionally check current connectivity at any time
  Future<ConnectivityResult> checkConnectivity() async {
    return _connectivity.checkConnectivity();
  }

  // Dispose the controller if needed
  void dispose() {
    _controller.close();
  }
}
