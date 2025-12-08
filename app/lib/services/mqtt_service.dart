import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';

class MqttService {
  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  final _joinController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get joinStream => _joinController.stream;

  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  final _lwtController = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get lwtStream => _lwtController.stream;

  late MqttClient _client;

  Future<void> connect({required String host, int port = 8883, bool secure = true}) async {
    _client = MqttClient(host, 'smarthome-mobile-${DateTime.now().millisecondsSinceEpoch}');
    _client.port = port;
    _client.logging(on: false);
    _client.secure = secure;
    _client.keepAlivePeriod = 30;
    _client.onConnected = () => _connectionController.add(true);
    _client.onDisconnected = () => _connectionController.add(false);
    _client.onSubscribed = (_) {};

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier!)
        .startClean();
    _client.connectionMessage = connMess;

    await _client.connect();
    final base = 'smarthome';
    _client.subscribe('$base/+/join', MqttQos.atLeastOnce);
    _client.subscribe('$base/+/status', MqttQos.atLeastOnce);
    _client.subscribe('$base/+/lwt', MqttQos.atLeastOnce);

    _client.updates?.listen((events) {
      final rec = events.first;
      final topic = rec.topic;
      final payload = (rec.payload as MqttPublishMessage).payload.message;
      final data = String.fromCharCodes(payload);
      final parts = topic.split('/');
      final suffix = parts.last;
      if (suffix == 'lwt') {
        _lwtController.add({'node': parts[1], 'state': data});
        return;
      }
      try {
        final json = rec.payload is MqttPublishMessage ? rec.payload as MqttPublishMessage : null;
        final parsed = jsonDecode(data) as Map<String, dynamic>;
        if (suffix == 'join') _joinController.add(parsed);
        if (suffix == 'status') _statusController.add(parsed);
      } catch (_) {}
    });
  }

  Future<void> sendToggle(String fullDevId, bool state) async {
    final parts = fullDevId.split(':');
    final nodeId = parts.first;
    final payload = {'t': 'cmd', 'dev': fullDevId, 'st': state ? 1 : 0};
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode(payload));
    _client.publishMessage('smarthome/$nodeId/cmd', MqttQos.atLeastOnce, builder.payload!);
  }
}
