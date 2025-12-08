/// Basic automation scene model.
class SceneModel {
  final String id;
  final String name;
  final String icon;
  final List<SceneAction> actions;

  const SceneModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.actions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'actions': actions.map((e) => e.toJson()).toList(),
      };

  factory SceneModel.fromJson(Map<String, dynamic> json) => SceneModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        actions: (json['actions'] as List<dynamic>)
            .map((e) => SceneAction.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class SceneAction {
  final String dev;
  final int st;

  const SceneAction({required this.dev, required this.st});

  Map<String, dynamic> toJson() => {'dev': dev, 'st': st};

  factory SceneAction.fromJson(Map<String, dynamic> json) => SceneAction(
        dev: json['dev'] as String,
        st: json['st'] as int,
      );
}
