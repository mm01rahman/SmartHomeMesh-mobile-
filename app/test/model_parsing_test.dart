import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';
import 'package:smarthomemesh_app/data/models/node_model.dart';

void main() {
  test('parses join payload into models', () {
    const payload = '{"t":"join","node":"esp7","devs":[{"id":"L1","type":"light","label":"Ceiling Light"}]}'
        ;
    final map = jsonDecode(payload) as Map<String, dynamic>;
    final devices = DeviceModel.listFromJoin(map['node'] as String, map['devs'] as List<dynamic>);
    expect(devices.first.fullId, 'esp7:L1');
    expect(devices.first.type, DeviceType.light);
  });

  test('updates status payload', () {
    final node = NodeModel(
      id: 'esp7',
      label: 'Node',
      devices: const [DeviceModel(localId: 'L1', nodeId: 'esp7', type: DeviceType.light, label: 'Light', state: 0)],
      isOnline: false,
      lastSeen: DateTime(2023),
    );
    final status = {'node': 'esp7', 'devs': [{'id': 'L1', 'st': 1}]};
    final updated = DeviceModel.updateFromStatus(node.devices.first, status['devs']!.first);
    expect(updated.state, 1);
  });
}
