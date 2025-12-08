import 'package:smarthomemesh_app/data/models/device_model.dart';

/// Abstract interface for sending commands and listening for device updates.
abstract class DeviceControlService {
  Stream<DeviceStateUpdate> get deviceStateStream;

  /// Stream of JOIN payloads (when available). Non-MQTT transports may expose
  /// an empty stream.
  Stream<Map<String, dynamic>> get joinStream;

  /// Stream of STATUS payloads (when available). Non-MQTT transports may expose
  /// an empty stream.
  Stream<Map<String, dynamic>> get statusStream;

  /// Emits connection state for transports that support it so the UI can
  /// reflect online/offline MQTT reachability.
  Stream<bool> get connectionStateStream;

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
