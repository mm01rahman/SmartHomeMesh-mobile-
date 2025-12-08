import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalHttpService {
  final String baseUrl;
  LocalHttpService({this.baseUrl = 'http://192.168.4.1'});

  Future<void> sendToggle(String nodeId, String localId, bool state) async {
    final uri = Uri.parse('$baseUrl/cmd?dev=$nodeId:$localId&st=${state ? 1 : 0}');
    await http.get(uri);
  }

  Future<Map<String, dynamic>> getStatus([String? url]) async {
    final res = await http.get(Uri.parse('${url ?? baseUrl}/status'));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWifiInfo([String? url]) async {
    final res = await http.get(Uri.parse('${url ?? baseUrl}/wifi'));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> provisionWifi(String ssid, String pass, [String? url]) async {
    await http.post(Uri.parse('${url ?? baseUrl}/provision'), body: jsonEncode({'ssid': ssid, 'pass': pass}));
  }
}
