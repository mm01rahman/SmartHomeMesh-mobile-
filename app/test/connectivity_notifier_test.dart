import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthomemesh_app/core/utils/app_mode.dart';
import 'package:smarthomemesh_app/features/connectivity/application/connectivity_notifier.dart';

void main() {
  group('deriveMode', () {
    test('returns offline when no interfaces are available', () {
      final mode = deriveMode(connectivity: ConnectivityResult.none, mqttReachable: false);
      expect(mode, AppMode.offline);
    });

    test('prefers cloud when MQTT is reachable', () {
      final mode = deriveMode(connectivity: ConnectivityResult.wifi, mqttReachable: true);
      expect(mode, AppMode.cloudOnline);
    });

    test('detects AP mode when wifi looks like ESP hotspot', () {
      final mode = deriveMode(
        connectivity: ConnectivityResult.wifi,
        mqttReachable: false,
        wifiName: 'ESP_FF_AB',
      );
      expect(mode, AppMode.apLocalOnly);
    });

    test('falls back to local network without MQTT', () {
      final mode = deriveMode(connectivity: ConnectivityResult.mobile, mqttReachable: false);
      expect(mode, AppMode.localNetworkOnly);
    });
  });
}
