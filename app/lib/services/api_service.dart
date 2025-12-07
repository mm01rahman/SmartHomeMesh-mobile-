import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080')));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _attachToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response<T>> get<T>(String path) async {
    await _attachToken();
    return _dio.get(path);
  }

  Future<Response<T>> post<T>(String path, dynamic data) async {
    await _attachToken();
    return _dio.post(path, data: data);
  }

  Future<Response<T>> patch<T>(String path, dynamic data) async {
    await _attachToken();
    return _dio.patch(path, data: data);
  }
}
