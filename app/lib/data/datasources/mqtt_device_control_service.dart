import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:riverpod/riverpod.dart';
import 'package:smarthomemesh_app/data/services/device_control_service.dart';

/// MQTT implementation speaking the esp v2.0 topic contract.
class MqttDeviceControlService extends DeviceControlService {
  final MqttServerClient _client;
  final _controller = StreamController<DeviceStateUpdate>.broadcast();
  bool _subscribed = false;

  @override
  Stream<DeviceStateUpdate> get deviceStateStream => _controller.stream;

  MqttDeviceControlService(String host, {int port = 1883, String clientId = 'smarthomemesh_app'})
      : _client = MqttServerClient(host, clientId) {
    _client.logging(on: false);
    _client.port = port;
    _client.keepAlivePeriod = 30;
  }

  Future<void> connect() async {
    try {
      await _client.connect();
      _subscribe();
    } catch (_) {
      _client.disconnect();
      rethrow;
    }
  }

  Future<bool> ensureConnected() async {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      return true;
    }
    try {
      await connect();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _subscribe() {
    if (_subscribed) return;
    _subscribed = true;
    _client.subscribe('smarthome/status', MqttQos.atLeastOnce);
    _client.subscribe('smarthome/ack', MqttQos.atLeastOnce);
    _client.updates?.listen((messages) {
      for (final msg in messages) {
        final recMess = msg.payload as MqttPublishMessage;
        final payload = utf8.decode(recMess.payload.message);
        _handlePayload(payload);
      }
    });
  }

  void _handlePayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['t'] == 'status') {
        final node = data['node'] as String? ?? '';
        final devs = data['devs'] as List<dynamic>? ?? [];
        for (final dev in devs) {
          final id = dev['id'];
          final st = dev['st'];
          if (id != null && st is int) {
            _controller.add(DeviceStateUpdate(fullId: '$node:$id', state: st));
          }
        }
      } else if (data['t'] == 'ack' && data['dev'] is String && data['st'] is int) {
        _controller.add(DeviceStateUpdate(fullId: data['dev'] as String, state: data['st'] as int));
      }
    } catch (_) {
      // swallow malformed packets
    }
  }

  @override
  Future<void> sendCommand(String fullDevId, int state) async {
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode({'t': 'cmd', 'dev': fullDevId, 'st': state}));
    _client.publishMessage('smarthome/cmd', MqttQos.exactlyOnce, builder.payload!);
  }

  void dispose() {
    _controller.close();
    _client.disconnect();
  }
}

final mqttServiceProvider = Provider.family<MqttDeviceControlService, String>((ref, host) {
  final service = MqttDeviceControlService(host);
  return service;
});
