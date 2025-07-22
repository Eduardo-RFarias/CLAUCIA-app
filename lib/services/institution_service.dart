import 'package:dio/dio.dart';
import '../models/institution_model.dart';
import 'api_client.dart';

class InstitutionService {
  final Dio _dio = ApiClient().dio;

  Future<List<Institution>> getAllInstitutions() async {
    try {
      final res = await _dio.get('/institutions');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Institution.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch institutions',
      );
    }
  }

  Future<List<Institution>> getInstitutionsForProfessional(String coren) async {
    try {
      final res = await _dio.get('/institutions/professional/$coren');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Institution.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch professional institutions',
      );
    }
  }
}
