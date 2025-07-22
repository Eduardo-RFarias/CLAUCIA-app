import 'package:dio/dio.dart';
import '../models/wound_model.dart';
import '../dtos/create_wound_dto.dart';
import 'api_client.dart';

class WoundService {
  final Dio _dio = ApiClient().dio;

  Future<List<Wound>> getAllWounds() async {
    try {
      final res = await _dio.get('/wounds');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Wound.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch wounds');
    }
  }

  Future<List<Wound>> getWoundsByPatient(int patientId) async {
    try {
      final res = await _dio.get('/wounds/patient/$patientId');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Wound.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch wounds');
    }
  }

  Future<Wound> getWound(int id) async {
    try {
      final res = await _dio.get('/wounds/$id');
      return Wound.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch wound');
    }
  }

  Future<Wound> createWound(CreateWoundDto dto) async {
    try {
      final res = await _dio.post('/wounds', data: dto.toJson());
      return Wound.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create wound');
    }
  }

  Future<Wound> updateWound(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch('/wounds/$id', data: data);
      return Wound.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update wound');
    }
  }

  Future<void> deleteWound(int id) async {
    try {
      await _dio.delete('/wounds/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete wound');
    }
  }
}
