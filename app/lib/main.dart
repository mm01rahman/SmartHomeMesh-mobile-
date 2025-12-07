import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_list_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/room_detail_screen.dart';
import 'screens/nodes_screen.dart';
import 'screens/scenes_screen.dart';

void main() {
  runApp(const ProviderScope(child: SmartHomeApp()));
}

class SmartHomeApp extends ConsumerWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: '/auth',
      refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
      redirect: (context, state) {
        final loggedIn = auth.isAuthenticated;
        final loggingIn = state.subloc == '/auth';
        if (!loggedIn && !loggingIn) return '/auth';
        if (loggedIn && loggingIn) return '/homes';
        return null;
      },
      routes: [
        GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
        GoRoute(path: '/homes', builder: (context, state) => const HomeListScreen()),
        GoRoute(
          path: '/homes/:id',
          builder: (context, state) => HomeDashboardScreen(homeId: int.parse(state.params['id']!)),
        ),
        GoRoute(
          path: '/homes/:homeId/rooms/:roomId',
          builder: (context, state) => RoomDetailScreen(
            homeId: int.parse(state.params['homeId']!),
            roomId: int.parse(state.params['roomId']!),
          ),
        ),
        GoRoute(
          path: '/homes/:homeId/nodes',
          builder: (context, state) => NodesScreen(homeId: int.parse(state.params['homeId']!)),
        ),
        GoRoute(
          path: '/homes/:homeId/scenes',
          builder: (context, state) => ScenesScreen(homeId: int.parse(state.params['homeId']!)),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'SmartHomeMesh',
      routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
    );
  }
}
