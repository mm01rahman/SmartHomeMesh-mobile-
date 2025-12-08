import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smarthomemesh_app/data/datasources/local_cache_data_source.dart';
import 'package:smarthomemesh_app/data/models/node_model.dart';
import 'package:smarthomemesh_app/data/models/device_model.dart';
import 'package:smarthomemesh_app/data/repositories/node_repository.dart';
import 'package:smarthomemesh_app/data/services/device_control_service.dart';

class FakeService extends DeviceControlService {
  final _stream = Stream<DeviceStateUpdate>.empty();
  @override
  Stream<DeviceStateUpdate> get deviceStateStream => _stream;

  @override
  Future<void> sendCommand(String fullDevId, int state) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('caches node on join', () async {
    await Hive.initFlutter();
    await Hive.openBox(LocalCacheDataSource.nodesBox);
    final repo = NodeRepository(cache: LocalCacheDataSource(), controlService: FakeService());
    await repo.init();
    repo.ingestJoin({
      'node': 'esp7',
      'devs': [
        {'id': 'L1', 'type': 'light', 'label': 'Ceiling Light'},
      ],
    });
    final box = Hive.box(LocalCacheDataSource.nodesBox);
    expect(box.values.length, 1);
    final stored = NodeModel.fromJson(Map<String, dynamic>.from(box.values.first as Map));
    expect(stored.devices.first.fullId, 'esp7:L1');
  });
}
