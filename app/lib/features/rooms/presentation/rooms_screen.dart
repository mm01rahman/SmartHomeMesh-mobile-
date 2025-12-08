import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthomemesh_app/common/widgets/room_card.dart';
import 'package:smarthomemesh_app/data/models/room_model.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  static void open(BuildContext context) => context.go('/rooms');

  @override
  Widget build(BuildContext context) {
    final rooms = const [
      RoomModel(id: 'room1', name: 'Bedroom', icon: '🛏️', deviceFullIds: ['esp7:L1']),
      RoomModel(id: 'room2', name: 'Living', icon: '🛋️', deviceFullIds: ['esp7:F1']),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return RoomCard(
            room: room,
            activeCount: room.deviceFullIds.length,
            onTap: () => context.go('/rooms/detail/${room.id}'),
          );
        },
      ),
    );
  }
}
