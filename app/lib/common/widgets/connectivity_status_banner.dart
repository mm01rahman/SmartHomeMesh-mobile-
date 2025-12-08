import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthomemesh_app/core/utils/app_mode.dart';
import 'package:smarthomemesh_app/features/connectivity/application/connectivity_notifier.dart';

class ConnectivityStatusBanner extends ConsumerWidget {
  const ConnectivityStatusBanner({super.key});

  Color _colorForMode(AppMode mode) {
    switch (mode) {
      case AppMode.cloudOnline:
        return Colors.green;
      case AppMode.localNetworkOnly:
        return Colors.orange;
      case AppMode.apLocalOnly:
        return Colors.blue;
      case AppMode.offline:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectivityNotifierProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _colorForMode(state.mode).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud, color: _colorForMode(state.mode)),
          const SizedBox(width: 8),
          Text(state.mode.label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          if (state.isChecking) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}
