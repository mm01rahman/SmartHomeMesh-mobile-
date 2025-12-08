import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthomemesh_app/data/datasources/local_cache_data_source.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';
import 'package:smarthomemesh_app/data/models/node_model.dart';
import 'package:smarthomemesh_app/data/services/device_control_service.dart';

/// Repository handling node lifecycle, join/status parsing, and caching.
class NodeRepository {
  final LocalCacheDataSource cache;
  final DeviceControlService controlService;
  final _controller = StreamController<List<NodeModel>>.broadcast();
  late final Box _box;

  NodeRepository({required this.cache, required this.controlService});

  Stream<List<NodeModel>> get nodesStream => _controller.stream;

  Future<void> init() async {
    _box = cache.getBox(LocalCacheDataSource.nodesBox);
    final cached = _box.values.map((e) => NodeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    if (cached.isNotEmpty) {
      _controller.add(cached);
    }

    controlService.deviceStateStream.listen(_applyDeviceUpdate);
  }

  /// Handles JOIN payloads coming from MQTT.
  void ingestJoin(Map<String, dynamic> join) {
    final nodeId = join['node'] as String?;
    if (nodeId == null) return;
    final devs = join['devs'] as List<dynamic>? ?? [];
    final devices = DeviceModel.listFromJoin(nodeId, devs);
    final node = NodeModel(
      id: nodeId,
      label: nodeId,
      devices: devices,
      isOnline: true,
      lastSeen: DateTime.now(),
    );
    _saveNode(node);
  }

  /// Handles STATUS payloads.
  void ingestStatus(Map<String, dynamic> status) {
    final nodeId = status['node'] as String?;
    if (nodeId == null) return;
    final devs = status['devs'] as List<dynamic>? ?? [];
    final existing = _getNode(nodeId);
    if (existing == null) return;
    final updatedDevices = existing.devices.map((d) {
      final update = devs.firstWhere((e) => e['id'] == d.localId, orElse: () => null);
      if (update is Map<String, dynamic>) {
        return DeviceModel.updateFromStatus(d, update);
      }
      return d;
    }).toList();
    final node = existing.copyWith(devices: updatedDevices, isOnline: true, lastSeen: DateTime.now());
    _saveNode(node);
  }

  void _applyDeviceUpdate(DeviceStateUpdate update) {
    final parts = update.fullId.split(':');
    if (parts.length != 2) return;
    final nodeId = parts[0];
    final localId = parts[1];
    final existing = _getNode(nodeId);
    if (existing == null) return;
    final updatedDevices = existing.devices
        .map((d) => d.localId == localId ? d.copyWith(state: update.state) : d)
        .toList();
    _saveNode(existing.copyWith(devices: updatedDevices, lastSeen: DateTime.now()));
  }

  NodeModel? _getNode(String id) {
    final nodes = _box.values.map((e) => NodeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return nodes.firstWhere((e) => e.id == id, orElse: () => null);
  }

  void _saveNode(NodeModel node) {
    final nodes = _box.values.map((e) => NodeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    final index = nodes.indexWhere((n) => n.id == node.id);
    if (index >= 0) {
      _box.putAt(index, node.toJson());
      nodes[index] = node;
    } else {
      _box.add(node.toJson());
      nodes.add(node);
    }
    _controller.add(nodes);
  }
}
