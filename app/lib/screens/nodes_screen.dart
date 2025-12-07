import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NodesScreen extends StatefulWidget {
  const NodesScreen({super.key, required this.homeId});
  final int homeId;

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  List nodes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService().get('/homes/${widget.homeId}/nodes');
    setState(() => nodes = res.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nodes')),
      body: ListView.builder(
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          final n = nodes[index];
          return ListTile(
            title: Text(n['name'] ?? n['nodeId']),
            subtitle: Text('Status: ${n['onlineStatus']} | Last seen: ${n['lastSeenAt']}'),
          );
        },
      ),
    );
  }
}
