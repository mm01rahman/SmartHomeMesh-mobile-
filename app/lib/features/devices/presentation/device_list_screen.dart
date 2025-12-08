import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthomemesh_app/common/widgets/device_card.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  String query = '';
  DeviceType? filterType;

  final devices = const [
    DeviceModel(localId: 'L1', nodeId: 'esp7', type: DeviceType.light, label: 'Ceiling Light', state: 1),
    DeviceModel(localId: 'F1', nodeId: 'esp7', type: DeviceType.fan, label: 'Wall Fan', state: 0),
    DeviceModel(localId: 'S1', nodeId: 'esp9', type: DeviceType.socket, label: 'Power Socket', state: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = devices.where((d) {
      final matchesQuery = d.label.toLowerCase().contains(query.toLowerCase());
      final matchesFilter = filterType == null || filterType == d.type;
      return matchesQuery && matchesFilter;
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search devices'),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: DeviceType.values
                  .map((type) => FilterChip(
                        label: Text(type.name),
                        selected: filterType == type,
                        onSelected: (_) => setState(() => filterType = filterType == type ? null : type),
                      ))
                  .toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final device = filtered[index];
                  return DeviceCard(
                    device: device,
                    onToggle: (value) {},
                    isBusy: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/devices/detail/${filtered.first.fullId}'),
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}
