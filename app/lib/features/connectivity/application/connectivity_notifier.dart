import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthomemesh_app/core/utils/app_mode.dart';
import 'package:smarthomemesh_app/data/datasources/mqtt_device_control_service.dart';
import 'package:smarthomemesh_app/data/services/device_control_service.dart';

class ConnectivityState {
  final AppMode mode;
  final bool isChecking;
  final String description;

  const ConnectivityState({required this.mode, this.isChecking = false, this.description = ''});

  ConnectivityState copyWith({AppMode? mode, bool? isChecking, String? description}) => ConnectivityState(
        mode: mode ?? this.mode,
        isChecking: isChecking ?? this.isChecking,
        description: description ?? this.description,
      );
}

/// Listens to device connectivity and MQTT reachability to expose AppMode.
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final MqttDeviceControlService mqttService;
  StreamSubscription? _sub;

  ConnectivityNotifier({required this.mqttService}) : super(const ConnectivityState(mode: AppMode.offline));

  Future<void> init() async {
    state = state.copyWith(isChecking: true, description: 'Checking network...');
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      state = state.copyWith(mode: AppMode.offline, isChecking: false, description: 'No network');
      return;
    }
    try {
      await mqttService.connect();
      state = state.copyWith(mode: AppMode.cloudOnline, isChecking: false, description: 'MQTT connected');
    } catch (_) {
      state = state.copyWith(mode: AppMode.localNetworkOnly, isChecking: false, description: 'Broker unreachable');
    }
    _sub = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      state = state.copyWith(mode: AppMode.offline);
    }
  }

  DeviceControlService resolveTransport({String? espIp}) {
    switch (state.mode) {
      case AppMode.apLocalOnly:
        return HttpFallbackDeviceControlService(espIp ?? '192.168.4.1');
      case AppMode.cloudOnline:
      case AppMode.localNetworkOnly:
      case AppMode.offline:
        return mqttService;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class HttpFallbackDeviceControlService extends DeviceControlService {
  final String ip;
  HttpFallbackDeviceControlService(this.ip);

  @override
  Stream<DeviceStateUpdate> get deviceStateStream => const Stream.empty();

  @override
  Future<void> sendCommand(String fullDevId, int state) async {
    // Defer to dedicated HTTP service in real flow; placeholder keeps interface satisfied.
  }
}

final connectivityNotifierProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  final mqtt = MqttDeviceControlService('broker.hivemq.com');
  final notifier = ConnectivityNotifier(mqttService: mqtt);
  notifier.init();
  return notifier;
});
