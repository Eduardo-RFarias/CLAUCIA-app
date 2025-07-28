import 'package:dio/dio.dart';
import '../models/professional_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Dio get _dio => _apiClient.dio;

  /// Logs the professional in and returns a [Professional] with a JWT token.
  /// Throws an [Exception] if credentials are invalid or any other error occurs.
  Future<Professional> login(String coren, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login/professional',
        data: {'coren': coren, 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = response.data['access_token'] as String?;
        if (token == null) {
          throw Exception('API did not return an auth token');
        }

        // Persist token for subsequent requests
        setToken(token);

        // Fetch professional profile using the provided token
        // Manually add the Authorization header for this immediate request
        final profResponse = await _dio.get(
          '/professionals/$coren',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        if (profResponse.statusCode == 200) {
          return Professional.fromJson(
            profResponse.data as Map<String, dynamic>,
            token: token,
          );
        } else {
          throw Exception('Failed to fetch professional profile');
        }
      }
      throw Exception('Login failed with status code ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Login failed: ${e.message}',
      );
    }
  }

  Future<Professional> updatePhoto(String coren, String base64Photo) async {
    try {
      final res = await _dio.patch(
        '/professionals/$coren',
        data: {'photo': base64Photo},
      );
      return Professional.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update photo');
    }
  }

  Future<void> changePassword(String coren, String newPassword) async {
    try {
      await _dio.patch(
        '/professionals/$coren',
        data: {'password': newPassword},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to change password',
      );
    }
  }

  Future<void> logout() async {
    clearAllTokens();
    // If the backend has a logout endpoint, call it here.
    // await _dio.post('/auth/logout');
  }

  /// Clears all stored tokens (useful when token format changes)
  void clearAllTokens() {
    _apiClient.clearToken();
  }

  /// Sets the authentication token
  void setToken(String token) {
    _apiClient.setToken(token);
  }

  /// Fetches professional profile using existing token
  Future<Professional> fetchProfessionalProfile(
    String identifier,
    String token,
  ) async {
    try {
      final profResponse = await _dio.get(
        '/professionals/$identifier',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (profResponse.statusCode == 200) {
        return Professional.fromJson(
          profResponse.data as Map<String, dynamic>,
          token: token,
        );
      } else {
        throw Exception('Failed to fetch professional profile');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch profile: ${e.message}',
      );
    }
  }
}
