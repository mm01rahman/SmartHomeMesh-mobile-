import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get wifiConnectedStream => _controller.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((result) {
      _controller.add(result.contains(ConnectivityResult.wifi));
    });
  }
}
