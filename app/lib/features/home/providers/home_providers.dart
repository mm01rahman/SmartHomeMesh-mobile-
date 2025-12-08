import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_status.dart';
import '../../../models/app_mode.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/mqtt_service.dart';
import '../../../data/node_repository.dart';

final connectivityServiceProvider = Provider((ref) => ConnectivityService());

final appStatusProvider = StreamProvider<AppStatus>((ref) {
  final connectivity = ref.read(connectivityServiceProvider);
  final mqtt = ref.read(mqttServiceProvider);
  mqtt.connect(host: const String.fromEnvironment('MQTT_HOST', defaultValue: 'broker.example.com'));
  final wifiStream = connectivity.wifiConnectedStream;
  final mqttStream = mqtt.connectionStream;
  return StreamZip([wifiStream, mqttStream]).map((values) {
    final wifi = values[0] as bool;
    final mqttConn = values[1] as bool;
    AppMode mode = AppMode.offline;
    if (mqttConn) {
      mode = AppMode.cloudMqtt;
    } else if (wifi) {
      mode = AppMode.localStaHttp;
    }
    return AppStatus(
      mode: mode,
      mqttConnected: mqttConn,
      wifiConnected: wifi,
      apVisible: !wifi,
      lastUpdate: DateTime.now(),
    );
  });
});

final nodesProvider = StreamProvider((ref) => ref.read(nodeRepositoryProvider).watchNodes());
