import 'package:dio/dio.dart';
import '../models/sample_model.dart';
import '../dtos/create_sample_dto.dart';
import 'api_client.dart';

class SampleService {
  final Dio _dio = ApiClient().dio;

  Future<List<Sample>> getSamplesByWound(int woundId) async {
    try {
      final res = await _dio.get('/samples/wound/$woundId');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Sample.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch samples');
    }
  }

  Future<Sample> getSample(int id) async {
    try {
      final res = await _dio.get('/samples/$id');
      return Sample.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch sample');
    }
  }

  Future<Sample> createSample(CreateSampleDto dto) async {
    try {
      final res = await _dio.post('/samples', data: dto.toJson());
      return Sample.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create sample');
    }
  }

  Future<Sample> updateSample(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch('/samples/$id', data: data);
      return Sample.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update sample');
    }
  }

  Future<void> deleteSample(int id) async {
    try {
      await _dio.delete('/samples/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete sample');
    }
  }
}
