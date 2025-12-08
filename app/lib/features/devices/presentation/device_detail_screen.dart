import 'package:flutter/material.dart';
import 'package:smarthomemesh_app/common/widgets/device_card.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String fullId;

  const DeviceDetailScreen({super.key, required this.fullId});

  @override
  Widget build(BuildContext context) {
    final device = DeviceModel(
      localId: fullId.split(':').last,
      nodeId: fullId.split(':').first,
      type: DeviceType.light,
      label: 'Device $fullId',
      state: 1,
    );
    return Scaffold(
      appBar: AppBar(title: Text(device.label)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeviceCard(device: device, onToggle: (value) {}),
            const SizedBox(height: 12),
            Text('Node: ${device.nodeId}'),
            Text('Room: Unassigned'),
            const SizedBox(height: 12),
            const Text('Activity'),
            const ListTile(
              leading: Icon(Icons.history),
              title: Text('Turned ON'),
              subtitle: Text('Just now'),
            ),
          ],
        ),
      ),
    );
  }
}
