import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scenes_providers.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Scenes')),
      body: scenes.when(
        data: (data) => ListView(
          children: data
              .map((s) => ListTile(
                    title: Text(s['name']),
                    subtitle: Text('${(s['actions'] as List).length} devices'),
                    trailing: ElevatedButton(
                      onPressed: () => ref.read(backendApiProvider).activateScene(s['id'] as int),
                      child: const Text('Run'),
                    ),
                  ))
              .toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error $e')),
      ),
    );
  }
}
