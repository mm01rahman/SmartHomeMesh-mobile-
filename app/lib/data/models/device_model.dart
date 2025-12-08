import 'dart:convert';

enum DeviceType { light, fan, socket, other }

/// Model representing a logical device on a node.
class DeviceModel {
  final String localId;
  final String nodeId;
  final DeviceType type;
  final String label;
  final int state;
  final String? roomId;

  const DeviceModel({
    required this.localId,
    required this.nodeId,
    required this.type,
    required this.label,
    required this.state,
    this.roomId,
  });

  String get fullId => '$nodeId:$localId';

  DeviceModel copyWith({String? label, int? state, String? roomId}) {
    return DeviceModel(
      localId: localId,
      nodeId: nodeId,
      type: type,
      label: label ?? this.label,
      state: state ?? this.state,
      roomId: roomId ?? this.roomId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'nodeId': nodeId,
      'type': type.name,
      'label': label,
      'state': state,
      'roomId': roomId,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      localId: json['localId'] as String,
      nodeId: json['nodeId'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeviceType.other,
      ),
      label: json['label'] as String,
      state: json['state'] as int,
      roomId: json['roomId'] as String?,
    );
  }

  static List<DeviceModel> listFromJoin(String nodeId, List<dynamic> devs) {
    return devs
        .map(
          (e) => DeviceModel(
            localId: e['id'] as String,
            nodeId: nodeId,
            type: _typeFromJoin(e['type'] as String?),
            label: e['label'] as String? ?? 'Device',
            state: e['st'] is int ? e['st'] as int : 0,
          ),
        )
        .toList();
  }

  static DeviceType _typeFromJoin(String? type) {
    switch (type) {
      case 'light':
        return DeviceType.light;
      case 'fan':
        return DeviceType.fan;
      case 'socket':
        return DeviceType.socket;
      default:
        return DeviceType.other;
    }
  }

  static DeviceModel updateFromStatus(DeviceModel device, Map<String, dynamic> status) {
    final st = status['st'];
    return device.copyWith(state: st is int ? st : device.state);
  }

  @override
  String toString() => jsonEncode(toJson());
}
