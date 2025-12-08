import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart' as mqtt;
import 'package:riverpod/riverpod.dart';
import 'package:smarthomemesh_app/data/models/mqtt_broker_config.dart';
import 'package:smarthomemesh_app/data/services/device_control_service.dart';

/// MQTT implementation speaking the esp v2.0 topic contract with TLS support.
class MqttDeviceControlService extends DeviceControlService {
  final MqttBrokerConfig _config;
  final mqtt.MqttServerClient _client;
  final _deviceUpdates = StreamController<DeviceStateUpdate>.broadcast();
  final _joinUpdates = StreamController<Map<String, dynamic>>.broadcast();
  final _statusUpdates = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionState = StreamController<bool>.broadcast();
  bool _subscribed = false;

  @override
  Stream<DeviceStateUpdate> get deviceStateStream => _deviceUpdates.stream;

  @override
  Stream<Map<String, dynamic>> get joinStream => _joinUpdates.stream;

  @override
  Stream<Map<String, dynamic>> get statusStream => _statusUpdates.stream;

  @override
  Stream<bool> get connectionStateStream => _connectionState.stream;

  MqttDeviceControlService(MqttBrokerConfig config)
      : _config = config,
        _client = mqtt.MqttServerClient.withPort(config.host, config.clientId, config.port) {
    _client.logging(on: false);
    _client.keepAlivePeriod = 30;
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;
    _client.secure = _config.useTls;

    if (_config.useTls) {
      final context = SecurityContext(withTrustedRoots: !_config.allowInsecure);
      if (_config.caCertificate != null) {
        context.setTrustedCertificatesBytes(utf8.encode(_config.caCertificate!));
      }
      _client.securityContext = context;
      _client.onBadCertificate = (_) => _config.allowInsecure;
    }

    _client.onConnected = () => _connectionState.add(true);
    _client.onDisconnected = () {
      _connectionState.add(false);
      _subscribed = false;
    };
    _client.onAutoReconnect = () => _connectionState.add(false);
    _client.onAutoReconnected = () => _connectionState.add(true);

    final connMessage = mqtt.MqttConnectMessage()
        .withClientIdentifier(_config.clientId)
        .startClean()
        .withWillTopic(_config.lwtTopic)
        .withWillMessage(jsonEncode({'t': 'lwt', 'st': 'offline', 'node': _config.clientId}))
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    if (_config.username != null && _config.password != null) {
      connMessage.authenticateAs(_config.username!, _config.password!);
    }
    _client.connectionMessage = connMessage;
  }

  Future<void> connect() async {
    try {
      await _client.connect();
      _connectionState.add(true);
      _subscribe();
    } catch (_) {
      _client.disconnect();
      _connectionState.add(false);
      rethrow;
    }
  }

  Future<bool> ensureConnected() async {
    if (_client.connectionStatus?.state == mqtt.MqttConnectionState.connected) {
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
    if (_subscribed || _client.connectionStatus?.state != mqtt.MqttConnectionState.connected) return;
    _subscribed = true;
    _client.subscribe(_config.statusTopic, mqtt.MqttQos.atLeastOnce);
    _client.subscribe(_config.ackTopic, mqtt.MqttQos.atLeastOnce);
    _client.subscribe(_config.joinTopic, mqtt.MqttQos.atLeastOnce);
    _client.subscribe('${_config.lwtTopic}/#', mqtt.MqttQos.atLeastOnce);

    _client.updates?.listen((messages) {
      for (final msg in messages) {
        final recMess = msg.payload as mqtt.MqttPublishMessage;
        final payload = utf8.decode(recMess.payload.message);
        _handlePayload(msg.topic, payload);
      }
    });
  }

  void _handlePayload(String topic, String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['t'] as String?;
      if (type == 'join' || topic == _config.joinTopic) {
        _joinUpdates.add(data);
      } else if (type == 'status' || topic.startsWith(_config.statusTopic)) {
        _statusUpdates.add(data);
        _emitDeviceStatesFromStatus(data);
      } else if (type == 'ack' || topic == _config.ackTopic) {
        _emitAck(data);
      } else if (type == 'lwt' || topic.startsWith(_config.lwtTopic)) {
        _handleLwt(data);
      }
    } catch (_) {
      // swallow malformed packets
    }
  }

  void _emitDeviceStatesFromStatus(Map<String, dynamic> data) {
    final node = data['node'] as String? ?? '';
    final devs = data['devs'] as List<dynamic>? ?? [];
    for (final dev in devs) {
      final id = dev['id'];
      final st = dev['st'];
      if (id != null && st is int) {
        _deviceUpdates.add(DeviceStateUpdate(fullId: '$node:$id', state: st));
      }
    }
  }

  void _emitAck(Map<String, dynamic> data) {
    if (data['dev'] is String && data['st'] is int) {
      _deviceUpdates.add(DeviceStateUpdate(fullId: data['dev'] as String, state: data['st'] as int));
    }
  }

  void _handleLwt(Map<String, dynamic> data) {
    final nodeId = data['node'] as String?;
    if (nodeId == null) return;
    final online = (data['st'] == 'online') || (data['online'] == true);
    _statusUpdates.add({'node': nodeId, 'online': online});
  }

  @override
  Future<void> sendCommand(String fullDevId, int state) async {
    final builder = mqtt.MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode({'t': 'cmd', 'dev': fullDevId, 'st': state}));
    _client.publishMessage(_config.cmdTopic, mqtt.MqttQos.exactlyOnce, builder.payload!);
  }

  void dispose() {
    _deviceUpdates.close();
    _statusUpdates.close();
    _joinUpdates.close();
    _connectionState.close();
    _client.disconnect();
  }
}

final mqttServiceProvider = Provider.family<MqttDeviceControlService, MqttBrokerConfig>((ref, config) {
  final service = MqttDeviceControlService(config);
  return service;
});
