import 'device_model.dart';

/// Represents an ESP node in the mesh.
class NodeModel {
  final String id;
  final String label;
  final List<DeviceModel> devices;
  final bool isOnline;
  final DateTime lastSeen;

  const NodeModel({
    required this.id,
    required this.label,
    required this.devices,
    required this.isOnline,
    required this.lastSeen,
  });

  NodeModel copyWith({
    String? label,
    List<DeviceModel>? devices,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return NodeModel(
      id: id,
      label: label ?? this.label,
      devices: devices ?? this.devices,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'devices': devices.map((e) => e.toJson()).toList(),
        'isOnline': isOnline,
        'lastSeen': lastSeen.toIso8601String(),
      };

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
        id: json['id'] as String,
        label: json['label'] as String,
        devices: (json['devices'] as List<dynamic>).map((e) => DeviceModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        isOnline: json['isOnline'] as bool,
        lastSeen: DateTime.parse(json['lastSeen'] as String),
      );
}
