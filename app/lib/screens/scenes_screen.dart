import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ScenesScreen extends StatefulWidget {
  const ScenesScreen({super.key, required this.homeId});
  final int homeId;

  @override
  State<ScenesScreen> createState() => _ScenesScreenState();
}

class _ScenesScreenState extends State<ScenesScreen> {
  List scenes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService().get('/homes/${widget.homeId}/scenes');
    setState(() => scenes = res.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scenes')),
      body: ListView(
        children: scenes
            .map(
              (s) => ListTile(
                title: Text(s['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => ApiService().post('/scenes/${s['id']}/run', {}),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
