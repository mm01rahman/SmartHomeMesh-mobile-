import 'package:flutter/material.dart';
import 'package:smarthomemesh_app/data/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final int activeCount;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(child: Text(room.icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name, style: Theme.of(context).textTheme.titleMedium),
                    Text('$activeCount active', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
