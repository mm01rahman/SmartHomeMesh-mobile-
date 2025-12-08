/// Model representing a room grouping devices.
class RoomModel {
  final String id;
  final String name;
  final String icon;
  final List<String> deviceFullIds;

  const RoomModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.deviceFullIds,
  });

  RoomModel copyWith({String? name, String? icon, List<String>? deviceFullIds}) => RoomModel(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        deviceFullIds: deviceFullIds ?? this.deviceFullIds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'deviceFullIds': deviceFullIds,
      };

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        deviceFullIds: List<String>.from(json['deviceFullIds'] as List<dynamic>),
      );
}
