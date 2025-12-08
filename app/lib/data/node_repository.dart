import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/node.dart';
import '../models/device.dart';
import '../models/app_mode.dart';
import '../services/mqtt_service.dart';
import '../services/local_http_service.dart';

class NodeRepository {
  final MqttService mqttService;
  final LocalHttpService localHttpService;
  final _nodes = <String, Node>{};

  NodeRepository({required this.mqttService, required this.localHttpService});

  Stream<List<Node>> watchNodes() async* {
    mqttService.joinStream.listen(_handleJoin);
    mqttService.statusStream.listen(_handleStatus);
    mqttService.lwtStream.listen((event) {
      final node = _nodes[event['node']];
      if (node != null) {
        _nodes[event['node']!] = node.copyWith(online: event['state']?.toUpperCase() == 'ONLINE');
        _controller.add(_nodes.values.toList());
      }
    });
    yield* _controller.stream;
  }

  final _controller = StreamController<List<Node>>.broadcast();

  void _handleJoin(Map<String, dynamic> msg) {
    final nodeId = msg['node'] as String;
    final devs = (msg['devs'] as List<dynamic>).map((d) => Device.fromStatus(d, nodeId)).toList();
    final node = _nodes[nodeId];
    _nodes[nodeId] = Node(id: nodeId, name: node?.name ?? nodeId, online: true, devices: devs);
    _controller.add(_nodes.values.toList());
  }

  void _handleStatus(Map<String, dynamic> msg) {
    final nodeId = msg['node'] as String;
    final node = _nodes[nodeId];
    final updatedDevs = (msg['devs'] as List<dynamic>).map((d) => Device.fromStatus(d, nodeId)).toList();
    if (node != null) {
      _nodes[nodeId] = node.copyWith(devices: updatedDevs, online: true);
    } else {
      _nodes[nodeId] = Node(id: nodeId, name: nodeId, online: true, devices: updatedDevs);
    }
    _controller.add(_nodes.values.toList());
  }

  Future<void> toggleDevice(Device device, bool newState, AppMode mode) async {
    if (mode == AppMode.cloudMqtt) {
      await mqttService.sendToggle(device.fullId, newState);
    } else if (mode == AppMode.localAp || mode == AppMode.localStaHttp) {
      await localHttpService.sendToggle(device.nodeId, device.localId, newState);
    } else {
      throw Exception('Offline');
    }
  }
}

final mqttServiceProvider = Provider((ref) => MqttService());
final localHttpServiceProvider = Provider((ref) => LocalHttpService());
final nodeRepositoryProvider = Provider((ref) => NodeRepository(
      mqttService: ref.read(mqttServiceProvider),
      localHttpService: ref.read(localHttpServiceProvider),
    ));
final nodesProvider = StreamProvider<List<Node>>((ref) => ref.read(nodeRepositoryProvider).watchNodes());
