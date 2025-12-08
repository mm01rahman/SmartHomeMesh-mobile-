import 'device.dart';

class Node {
  final String id;
  final String name;
  final bool online;
  final List<Device> devices;

  Node({required this.id, required this.name, required this.online, required this.devices});

  Node copyWith({String? name, bool? online, List<Device>? devices}) {
    return Node(
      id: id,
      name: name ?? this.name,
      online: online ?? this.online,
      devices: devices ?? this.devices,
    );
  }
}
