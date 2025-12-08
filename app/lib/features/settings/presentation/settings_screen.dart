import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusEchoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: status.when(
          data: (s) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('App mode: ${s.mode.name}'),
              Text('MQTT connected: ${s.mqttConnected}'),
              Text('WiFi connected: ${s.wifiConnected}'),
              Text('Last update: ${s.lastUpdate}'),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error $e'),
        ),
      ),
    );
  }
}
