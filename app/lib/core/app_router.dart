import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/nodes/presentation/node_list_screen.dart';
import '../features/nodes/presentation/node_detail_screen.dart';
import '../features/provisioning/presentation/provisioning_screen.dart';
import '../features/scenes/presentation/scenes_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/nodes', builder: (context, state) => const NodeListScreen()),
    GoRoute(path: '/nodes/:nodeId', builder: (context, state) => NodeDetailScreen(nodeId: state.pathParameters['nodeId']!)),
    GoRoute(path: '/provision', builder: (context, state) => const ProvisioningScreen()),
    GoRoute(path: '/scenes', builder: (context, state) => const ScenesScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);
