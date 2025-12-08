import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smarthomemesh_app/common/widgets/connectivity_status_banner.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';
import 'package:smarthomemesh_app/data/models/node_model.dart';
import 'package:smarthomemesh_app/data/models/room_model.dart';
import 'package:smarthomemesh_app/data/models/scene_model.dart';
import 'package:smarthomemesh_app/features/rooms/presentation/rooms_screen.dart';

final dashboardNodesProvider = Provider<List<NodeModel>>((ref) {
  return [
    NodeModel(
      id: 'esp7',
      label: 'Bedroom Node',
      devices: const [
        DeviceModel(localId: 'L1', nodeId: 'esp7', type: DeviceType.light, label: 'Ceiling Light', state: 1),
        DeviceModel(localId: 'F1', nodeId: 'esp7', type: DeviceType.fan, label: 'Wall Fan', state: 0),
      ],
      isOnline: true,
      lastSeen: DateTime.now(),
    ),
  ];
});

final dashboardRoomsProvider = Provider<List<RoomModel>>((ref) {
  return const [
    RoomModel(id: 'room1', name: 'Bedroom', icon: '🛏️', deviceFullIds: ['esp7:L1', 'esp7:F1']),
    RoomModel(id: 'room2', name: 'Living', icon: '🛋️', deviceFullIds: []),
  ];
});

final dashboardScenesProvider = Provider<List<SceneModel>>((ref) {
  return const [
    SceneModel(id: 'scene1', name: 'All Lights Off', icon: '🌙', actions: [SceneAction(dev: 'esp7:L1', st: 0)]),
    SceneModel(id: 'scene2', name: 'Movie Mode', icon: '🎬', actions: [SceneAction(dev: 'esp7:L1', st: 0)]),
  ];
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(dashboardNodesProvider);
    final rooms = ref.watch(dashboardRoomsProvider);
    final scenes = ref.watch(dashboardScenesProvider);
    final totalDevices = nodes.fold<int>(0, (sum, n) => sum + n.devices.length);
    final formatter = DateFormat('jm');

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('SmartHomeMesh'),
            actions: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ConnectivityStatusBanner(),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Good Evening, User', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('${nodes.length} nodes online · $totalDevices devices · ${rooms.length} rooms'),
                const SizedBox(height: 16),
                Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: scenes
                      .map((scene) => ElevatedButton.icon(
                            onPressed: () {},
                            icon: Text(scene.icon, style: const TextStyle(fontSize: 16)),
                            label: Text(scene.name),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(140, 48)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Rooms', style: Theme.of(context).textTheme.titleMedium),
                    TextButton(onPressed: () => RoomsScreen.open(context), child: const Text('See all')),
                  ],
                ),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final active = nodes
                          .expand((n) => n.devices)
                          .where((d) => room.deviceFullIds.contains(d.fullId) && d.state == 1)
                          .length;
                      return Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 8),
                            Text(room.name, style: Theme.of(context).textTheme.titleMedium),
                            Text('$active active devices'),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: rooms.length,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
                ...nodes.expand((n) => n.devices).map((d) => ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('${d.label} turned ${d.state == 1 ? 'ON' : 'OFF'}'),
                      subtitle: Text('${nodelabel(d.nodeId, nodes)} · ${formatter.format(DateTime.now())}'),
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String nodelabel(String id, List<NodeModel> nodes) => nodes.firstWhere((n) => n.id == id, orElse: () => nodes.first).label;
}
