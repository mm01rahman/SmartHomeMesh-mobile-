import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/node_repository.dart';
import '../providers/home_providers.dart';
import '../widgets/connection_banner.dart';
import '../widgets/room_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appStatusProvider);
    final nodesAsync = ref.watch(nodesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Home Mesh')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Navigation')),
            ListTile(
              title: const Text('Nodes'),
              onTap: () => Navigator.pushNamed(context, '/nodes'),
            ),
            ListTile(
              title: const Text('Scenes'),
              onTap: () => Navigator.pushNamed(context, '/scenes'),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            status.when(
              data: (s) => ConnectionBanner(status: s),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: nodesAsync.when(
                data: (nodes) => ListView(
                  children: nodes.map((n) => RoomCard(node: n)).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
