class Device {
  final String nodeId;
  final String localId;
  final String type;
  final String label;
  final bool state;
  final int? roomId;

  Device({
    required this.nodeId,
    required this.localId,
    required this.type,
    required this.label,
    required this.state,
    this.roomId,
  });

  String get fullId => '$nodeId:$localId';

  Device copyWith({bool? state, String? label, int? roomId}) {
    return Device(
      nodeId: nodeId,
      localId: localId,
      type: type,
      label: label ?? this.label,
      state: state ?? this.state,
      roomId: roomId ?? this.roomId,
    );
  }

  factory Device.fromStatus(Map<String, dynamic> json, String nodeId) {
    return Device(
      nodeId: nodeId,
      localId: json['id'] as String,
      type: json['type'] as String? ?? 'custom',
      label: json['label'] as String? ?? json['id'] as String,
      state: (json['st'] ?? json['state'] ?? 0) == 1,
      roomId: json['roomId'] as int?,
    );
  }
}
