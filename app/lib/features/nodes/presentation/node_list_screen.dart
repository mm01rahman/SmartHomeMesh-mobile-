import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/node_providers.dart';

class NodeListScreen extends ConsumerWidget {
  const NodeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodesAsync = ref.watch(nodesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nodes')),
      body: nodesAsync.when(
        data: (nodes) => ListView.builder(
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final node = nodes[index];
            final onCount = node.devices.where((d) => d.state).length;
            return ListTile(
              title: Text(node.name),
              subtitle: Text('${node.devices.length} devices • $onCount on'),
              trailing: Icon(Icons.circle, color: node.online ? Colors.green : Colors.red, size: 12),
              onTap: () => Navigator.pushNamed(context, '/nodes/${node.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error $e')),
      ),
    );
  }
}
