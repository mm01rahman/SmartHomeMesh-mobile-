import 'app_mode.dart';

class AppStatus {
  final AppMode mode;
  final bool mqttConnected;
  final bool wifiConnected;
  final bool apVisible;
  final DateTime lastUpdate;

  const AppStatus({
    required this.mode,
    required this.mqttConnected,
    required this.wifiConnected,
    required this.apVisible,
    required this.lastUpdate,
  });

  AppStatus copyWith({
    AppMode? mode,
    bool? mqttConnected,
    bool? wifiConnected,
    bool? apVisible,
    DateTime? lastUpdate,
  }) {
    return AppStatus(
      mode: mode ?? this.mode,
      mqttConnected: mqttConnected ?? this.mqttConnected,
      wifiConnected: wifiConnected ?? this.wifiConnected,
      apVisible: apVisible ?? this.apVisible,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
