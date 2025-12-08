import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApiService {
  final String baseUrl;
  String? token;
  BackendApiService({this.baseUrl = 'https://api.example.com/api', this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<List<dynamic>> listScenes(int homeId) async {
    final res = await http.get(Uri.parse('$baseUrl/homes/$homeId/scenes'), headers: _headers);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<void> activateScene(int sceneId) async {
    await http.post(Uri.parse('$baseUrl/scenes/$sceneId/activate'), headers: _headers);
  }
}
