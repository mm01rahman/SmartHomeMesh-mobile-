import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';

class DeviceCard extends ConsumerWidget {
  final DeviceModel device;
  final void Function(bool) onToggle;
  final bool isBusy;

  const DeviceCard({super.key, required this.device, required this.onToggle, this.isBusy = false});

  IconData _iconForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb_outline;
      case DeviceType.fan:
        return Icons.toys;
      case DeviceType.socket:
        return Icons.power_outlined;
      case DeviceType.other:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForType(device.type)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(device.label, style: Theme.of(context).textTheme.titleMedium),
                ),
                if (isBusy) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                Switch(
                  value: device.state == 1,
                  onChanged: isBusy ? null : onToggle,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Device ID: ${device.fullId}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
