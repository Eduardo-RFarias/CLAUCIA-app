import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storage.read<String>('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  late final Dio _dio;
  final GetStorage _storage = GetStorage();

  Dio get dio => _dio;

  void setToken(String token) {
    _storage.write('token', token);
  }

  void clearToken() {
    _storage.remove('token');
  }
}
