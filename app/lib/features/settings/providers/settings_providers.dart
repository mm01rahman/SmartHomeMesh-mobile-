import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_status.dart';
import '../../home/providers/home_providers.dart';

final statusEchoProvider = Provider<AsyncValue<AppStatus>>((ref) => ref.watch(appStatusProvider));
