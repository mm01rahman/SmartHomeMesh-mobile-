import 'package:flutter/material.dart';
import '../../../models/app_status.dart';
import '../../../models/app_mode.dart';

class ConnectionBanner extends StatelessWidget {
  final AppStatus status;
  const ConnectionBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    String text;
    switch (status.mode) {
      case AppMode.cloudMqtt:
        bg = Colors.green.shade100;
        text = 'Cloud MQTT connected';
        break;
      case AppMode.localAp:
        bg = Colors.orange.shade100;
        text = 'Local AP mode';
        break;
      case AppMode.localStaHttp:
        bg = Colors.blue.shade100;
        text = 'Local network HTTP';
        break;
      default:
        bg = Colors.red.shade100;
        text = 'Offline';
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 12),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
