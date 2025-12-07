import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomeListScreen extends ConsumerStatefulWidget {
  const HomeListScreen({super.key});

  @override
  ConsumerState<HomeListScreen> createState() => _HomeListScreenState();
}

class _HomeListScreenState extends ConsumerState<HomeListScreen> {
  List homes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService().get('/homes');
    setState(() => homes = res.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Homes'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: homes.length,
        itemBuilder: (context, index) {
          final home = homes[index];
          return ListTile(
            title: Text(home['name']),
            subtitle: Text('Timezone: ${home['timezone']}'),
            onTap: () => context.go('/homes/${home['id']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ApiService().post('/homes', {'name': 'New Home', 'timezone': 'UTC'});
          _load();
        },
        child: const Icon(Icons.add_home),
      ),
    );
  }
}
