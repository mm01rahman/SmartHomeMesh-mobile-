import 'package:flutter/material.dart';
import 'package:smarthomemesh_app/common/widgets/connectivity_status_banner.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ConnectivityStatusBanner(),
          const SizedBox(height: 12),
          const Text('Nodes & Network', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const ListTile(title: Text('esp7'), subtitle: Text('Online')), 
          const Divider(),
          const Text('MQTT Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextFormField(decoration: const InputDecoration(labelText: 'Host', hintText: 'broker.hivemq.com')),
          TextFormField(decoration: const InputDecoration(labelText: 'Port', hintText: '1883'), keyboardType: TextInputType.number),
          SwitchListTile(value: false, onChanged: (v) {}, title: const Text('TLS')),
          ElevatedButton(onPressed: () {}, child: const Text('Test MQTT Connection')),
          const Divider(),
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButtonFormField(
            items: const [DropdownMenuItem(value: 'system', child: Text('System')),
              DropdownMenuItem(value: 'light', child: Text('Light')),
              DropdownMenuItem(value: 'dark', child: Text('Dark'))],
            value: 'system',
            onChanged: (_) {},
          ),
          const Divider(),
          const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const ListTile(title: Text('SmartHomeMesh – esp v2.0'), subtitle: Text('Version 1.0.0')),
        ],
      ),
    );
  }
}
