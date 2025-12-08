import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provisioning_providers.dart';

class ProvisioningScreen extends ConsumerStatefulWidget {
  const ProvisioningScreen({super.key});

  @override
  ConsumerState<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends ConsumerState<ProvisioningScreen> {
  String ssid = '';
  String pass = '';
  String status = 'Connect to SmartHomeMesh AP then provision WiFi.';
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final http = ref.read(localHttpProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Provision device')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(status),
            TextField(
              decoration: const InputDecoration(labelText: 'SSID'),
              onChanged: (v) => ssid = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (v) => pass = v,
            ),
            ElevatedButton(
              onPressed: () async {
                await http.provisionWifi(ssid, pass);
                setState(() => status = 'Provisioned. Waiting for STA connection...');
                timer = Timer.periodic(const Duration(seconds: 3), (t) async {
                  final wifi = await http.getWifiInfo();
                  setState(() => status = wifi.toString());
                  if (wifi['sta_status'] == 'CONNECTED') {
                    t.cancel();
                    if (mounted) Navigator.pop(context);
                  }
                });
              },
              child: const Text('Provision'),
            ),
          ],
        ),
      ),
    );
  }
}
