import 'package:flutter/material.dart';
import '../../../models/node.dart';

class RoomCard extends StatelessWidget {
  final Node node;
  const RoomCard({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final onDevices = node.devices.where((d) => d.state).length;
    return Card(
      child: ListTile(
        title: Text(node.name),
        subtitle: Text('${node.devices.length} devices • $onDevices on'),
        trailing: Icon(Icons.circle, color: node.online ? Colors.green : Colors.red, size: 14),
      ),
    );
  }
}
