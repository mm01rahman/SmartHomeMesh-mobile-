import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('SmartHomeMesh – Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [isLogin, !isLogin],
              onPressed: (i) => setState(() => isLogin = i == 0),
              children: const [Padding(padding: EdgeInsets.all(8), child: Text('Sign In')), Padding(padding: EdgeInsets.all(8), child: Text('Sign Up'))],
            ),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            if (!isLogin) TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (isLogin) {
                  await ref.read(authProvider.notifier).signin(_email.text, _password.text);
                } else {
                  await ref.read(authProvider.notifier).signup(_email.text, _password.text, _name.text);
                }
              },
              child: Text(isLogin ? 'Sign In' : 'Sign Up'),
            ),
            if (auth.isAuthenticated) const Text('Logged in!'),
          ],
        ),
      ),
    );
  }
}
