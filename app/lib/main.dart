import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthomemesh_app/core/router/app_router.dart';
import 'package:smarthomemesh_app/core/theme/app_theme.dart';
import 'package:smarthomemesh_app/data/datasources/local_cache_data_source.dart';
import 'package:smarthomemesh_app/features/connectivity/application/connectivity_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cache = LocalCacheDataSource();
  await cache.init();
  runApp(ProviderScope(
    overrides: [],
    child: const SmartHomeMeshApp(),
  ));
}

class SmartHomeMeshApp extends ConsumerWidget {
  const SmartHomeMeshApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(connectivityNotifierProvider); // bootstrap connectivity
    return MaterialApp.router(
      title: 'SmartHomeMesh – esp v2.0',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
