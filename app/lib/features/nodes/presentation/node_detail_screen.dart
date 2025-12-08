import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/device.dart';
import '../../../models/app_mode.dart';
import '../../../data/node_repository.dart';
import '../providers/node_providers.dart';

class NodeDetailScreen extends ConsumerWidget {
  final String nodeId;
  const NodeDetailScreen({super.key, required this.nodeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodesAsync = ref.watch(nodesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Node $nodeId')),
      body: nodesAsync.when(
        data: (nodes) {
          final node = nodes.firstWhere((n) => n.id == nodeId);
          return ListView(
            children: node.devices
                .map(
                  (d) => SwitchListTile(
                    title: Text(d.label),
                    subtitle: Text('${d.type} • ${d.fullId}'),
                    value: d.state,
                    onChanged: (val) async {
                      try {
                        await ref.read(nodeRepositoryProvider).toggleDevice(d, val, AppMode.cloudMqtt);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    },
                  ),
                )
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error $e')),
      ),
    );
  }
}
