import 'package:hive_flutter/hive_flutter.dart';

/// Simple Hive-backed cache for persisting maps.
class LocalCacheDataSource {
  static const nodesBox = 'nodes_box';
  static const roomsBox = 'rooms_box';
  static const scenesBox = 'scenes_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(nodesBox);
    await Hive.openBox(roomsBox);
    await Hive.openBox(scenesBox);
  }

  Box getBox(String name) => Hive.box(name);
}
