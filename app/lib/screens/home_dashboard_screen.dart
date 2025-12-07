import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.homeId});
  final int homeId;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List rooms = [];
  List devices = [];
  List scenes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await ApiService().get('/homes/${widget.homeId}/rooms');
    final d = await ApiService().get('/homes/${widget.homeId}/devices');
    final s = await ApiService().get('/homes/${widget.homeId}/scenes');
    setState(() {
      rooms = r.data;
      devices = d.data;
      scenes = s.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home ${widget.homeId}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
            ...rooms.map((r) => ListTile(
                  title: Text(r['name']),
                  onTap: () => context.go('/homes/${widget.homeId}/rooms/${r['id']}'),
                )),
            const SizedBox(height: 12),
            const Text('Scenes'),
            ...scenes.map((s) => ListTile(
                  title: Text(s['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => ApiService().post('/scenes/${s['id']}/run', {}),
                  ),
                )),
            const SizedBox(height: 12),
            const Text('Devices'),
            ...devices.map((d) => SwitchListTile(
                  title: Text(d['label'] ?? 'Device'),
                  value: (d['currentState'] ?? 0) == 1,
                  onChanged: (v) async {
                    await ApiService().post('/devices/${d['id']}/command', {'state': v ? 1 : 0});
                    _load();
                  },
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/homes/${widget.homeId}/nodes'),
        child: const Icon(Icons.router),
      ),
    );
  }
}
