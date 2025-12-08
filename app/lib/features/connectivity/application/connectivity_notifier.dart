import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthomemesh_app/core/utils/app_mode.dart';
import 'package:smarthomemesh_app/data/datasources/http_device_control_service.dart';
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
  final HttpDeviceControlService httpService;
  StreamSubscription? _sub;

  ConnectivityNotifier({required this.mqttService, HttpDeviceControlService? httpService})
      : httpService = httpService ?? HttpDeviceControlService(baseIp: '192.168.4.1'),
        super(const ConnectivityState(mode: AppMode.offline));

  Future<void> init() async {
    state = state.copyWith(isChecking: true, description: 'Checking network...');
    final connectivity = await Connectivity().checkConnectivity();
    await _evaluateConnectivity(connectivity);
    _sub = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    await _evaluateConnectivity(result);
  }

  Future<void> _evaluateConnectivity(ConnectivityResult connectivity) async {
    if (connectivity == ConnectivityResult.none) {
      state = state.copyWith(mode: AppMode.offline, isChecking: false, description: 'No network');
      return;
    }

    final wifiName = connectivity == ConnectivityResult.wifi ? await _safeWifiName() : null;
    final mqttReachable = await mqttService.ensureConnected();
    final mode = deriveMode(connectivity: connectivity, mqttReachable: mqttReachable, wifiName: wifiName);
    state = state.copyWith(mode: mode, isChecking: false, description: _descriptionFor(mode));
  }

  String _descriptionFor(AppMode mode) {
    switch (mode) {
      case AppMode.cloudOnline:
        return 'MQTT connected';
      case AppMode.localNetworkOnly:
        return 'Broker unreachable';
      case AppMode.apLocalOnly:
        return 'ESP AP mode';
      case AppMode.offline:
        return 'No network';
    }
  }

  Future<String?> _safeWifiName() async {
    try {
      return await Connectivity().getWifiName();
    } catch (_) {
      return null;
    }
  }

  DeviceControlService resolveTransport({String? espIp}) {
    if (state.mode == AppMode.apLocalOnly && espIp != null && espIp.isNotEmpty) {
      return HttpDeviceControlService(baseIp: espIp);
    }
    if (state.mode == AppMode.apLocalOnly) {
      return httpService;
    }
    return mqttService;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final connectivityNotifierProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  final mqtt = MqttDeviceControlService('broker.hivemq.com');
  final notifier = ConnectivityNotifier(mqttService: mqtt);
  notifier.init();
  return notifier;
});

/// Maps connectivity + broker reachability to the desired app mode.
AppMode deriveMode({
  required ConnectivityResult connectivity,
  required bool mqttReachable,
  String? wifiName,
}) {
  if (connectivity == ConnectivityResult.none) return AppMode.offline;
  if (mqttReachable) return AppMode.cloudOnline;
  if (connectivity == ConnectivityResult.wifi && _looksLikeEspAp(wifiName)) {
    return AppMode.apLocalOnly;
  }
  return AppMode.localNetworkOnly;
}

bool _looksLikeEspAp(String? wifiName) {
  if (wifiName == null) return false;
  final normalized = wifiName.toLowerCase();
  return normalized.startsWith('esp') || normalized.contains('smarthomemesh') || normalized.contains('mesh-ap');
}
