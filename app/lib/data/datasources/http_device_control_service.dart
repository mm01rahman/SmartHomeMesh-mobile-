import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smarthomemesh_app/data/services/device_control_service.dart';

/// HTTP control service used when the app connects to ESP AP mode.
class HttpDeviceControlService extends DeviceControlService {
  final String baseIp;
  final _controller = StreamController<DeviceStateUpdate>.broadcast();

  HttpDeviceControlService({required this.baseIp});

  @override
  Stream<DeviceStateUpdate> get deviceStateStream => _controller.stream;

  @override
  Future<void> sendCommand(String fullDevId, int state) async {
    final uri = Uri.parse('http://$baseIp/cmd');
    await http.post(uri, body: jsonEncode({'dev': fullDevId, 'st': state}), headers: {'Content-Type': 'application/json'});
  }

  /// Polls the ESP AP status endpoint to emit updates to the UI.
  Future<void> pollStatus() async {
    final uri = Uri.parse('http://$baseIp/status');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['devs'] is List) {
        for (final dev in data['devs'] as List<dynamic>) {
          final id = dev['id'];
          final st = dev['st'];
          final node = data['node'] as String? ?? 'node';
          if (id != null && st is int) {
            _controller.add(DeviceStateUpdate(fullId: '$node:$id', state: st));
          }
        }
      }
    }
  }

  void dispose() => _controller.close();
}
