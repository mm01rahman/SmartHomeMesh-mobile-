import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/backend_api_service.dart';

final backendApiProvider = Provider((ref) => BackendApiService());
final scenesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  // replace home id with persisted selection
  const homeId = 1;
  return ref.read(backendApiProvider).listScenes(homeId);
});
