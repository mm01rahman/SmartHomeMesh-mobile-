import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_router.dart';
import 'core/theme.dart';

void main() {
  runApp(const ProviderScope(child: SmartHomeApp()));
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: appTheme,
      routerConfig: appRouter,
      title: 'SmartHomeMesh',
    );
  }
}
