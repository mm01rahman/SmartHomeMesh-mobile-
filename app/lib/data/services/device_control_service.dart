import 'package:smarthomemesh_app/data/models/device_model.dart';

/// Abstract interface for sending commands and listening for device updates.
abstract class DeviceControlService {
  Stream<DeviceStateUpdate> get deviceStateStream;
  Future<void> sendCommand(String fullDevId, int state);
}

/// Data emitted when devices report state changes.
class DeviceStateUpdate {
  final String fullId;
  final int state;
  final DateTime timestamp;

  DeviceStateUpdate({required this.fullId, required this.state, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}
