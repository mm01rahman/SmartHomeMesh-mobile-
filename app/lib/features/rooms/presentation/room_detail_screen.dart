import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthomemesh_app/common/widgets/device_card.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final devices = const [
      DeviceModel(localId: 'L1', nodeId: 'esp7', type: DeviceType.light, label: 'Ceiling Light', state: 1),
      DeviceModel(localId: 'F1', nodeId: 'esp7', type: DeviceType.fan, label: 'Wall Fan', state: 0),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Room $roomId')),
      body: GridView.count(
        crossAxisCount: 2,
        children: devices
            .map((d) => DeviceCard(
                  device: d,
                  onToggle: (v) {},
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pop(),
        label: const Text('Add Device'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
