import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key, required this.homeId, required this.roomId});
  final int homeId;
  final int roomId;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  List devices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService().get('/homes/${widget.homeId}/devices');
    setState(() => devices = res.data.where((d) => d['roomId'] == widget.roomId).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room ${widget.roomId}')),
      body: ListView(
        children: devices.map((d) => SwitchListTile(
              title: Text(d['label'] ?? 'Device'),
              value: (d['currentState'] ?? 0) == 1,
              onChanged: (v) async {
                await ApiService().post('/devices/${d['id']}/command', {'state': v ? 1 : 0});
                _load();
              },
            )).toList(),
      ),
    );
  }
}
