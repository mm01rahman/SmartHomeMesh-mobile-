import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthomemesh_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:smarthomemesh_app/features/devices/presentation/device_detail_screen.dart';
import 'package:smarthomemesh_app/features/devices/presentation/device_list_screen.dart';
import 'package:smarthomemesh_app/features/rooms/presentation/room_detail_screen.dart';
import 'package:smarthomemesh_app/features/rooms/presentation/rooms_screen.dart';
import 'package:smarthomemesh_app/features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.meeting_room_outlined), label: 'Rooms'),
                NavigationDestination(icon: Icon(Icons.devices_other), label: 'Devices'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/rooms', builder: (context, state) => const RoomsScreen(), routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) => RoomDetailScreen(roomId: state.pathParameters['id']!),
              ),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/devices', builder: (context, state) => const DeviceListScreen(), routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) => DeviceDetailScreen(fullId: state.pathParameters['id']!),
              ),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen())]),
        ],
      ),
    ],
  );
});
