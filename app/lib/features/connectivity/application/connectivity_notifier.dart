import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:smarthomemesh_app/core/utils/app_mode.dart';
import 'package:smarthomemesh_app/data/datasources/http_device_control_service.dart';
import 'package:smarthomemesh_app/data/datasources/mqtt_device_control_service.dart';
import 'package:smarthomemesh_app/data/models/mqtt_broker_config.dart';
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
  final NetworkInfo _networkInfo;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityNotifier({
    required this.mqttService,
    HttpDeviceControlService? httpService,
    NetworkInfo? networkInfo,
  })  : httpService = httpService ?? HttpDeviceControlService(baseIp: '192.168.4.1'),
        _networkInfo = networkInfo ?? NetworkInfo(),
        super(const ConnectivityState(mode: AppMode.offline));

  Future<void> init() async {
    state = state.copyWith(isChecking: true, description: 'Checking network...');
    final connectivity = await Connectivity().checkConnectivity();
    await _evaluateConnectivity(connectivity);
    _sub = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    await _evaluateConnectivity(results);
  }

  Future<void> _evaluateConnectivity(List<ConnectivityResult> connectivityResults) async {
    final connectivity = _primaryConnectivity(connectivityResults);
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
      return await _networkInfo.getWifiName();
    } catch (_) {
      return null;
    }
  }

  ConnectivityResult _primaryConnectivity(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityResult.none;
    if (results.contains(ConnectivityResult.wifi)) return ConnectivityResult.wifi;
    if (results.contains(ConnectivityResult.ethernet)) return ConnectivityResult.ethernet;
    if (results.contains(ConnectivityResult.mobile)) return ConnectivityResult.mobile;
    return results.first;
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
  final mqttConfig = MqttBrokerConfig(host: 'broker.hivemq.com', port: 8883, topicPrefix: 'smarthome');
  final mqtt = MqttDeviceControlService(mqttConfig);
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
