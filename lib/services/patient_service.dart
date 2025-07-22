import 'package:dio/dio.dart';
import '../models/patient_model.dart';
import '../dtos/create_patient_dto.dart';
import 'api_client.dart';

class PatientService {
  final Dio _dio = ApiClient().dio;

  Future<List<Patient>> getAllPatients() async {
    try {
      final res = await _dio.get('/patients');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch patients',
      );
    }
  }

  Future<List<Patient>> getPatientsByInstitution(String institutionName) async {
    try {
      final res = await _dio.get('/patients/institution/$institutionName');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch patients',
      );
    }
  }

  Future<Patient> getPatient(int id) async {
    try {
      final res = await _dio.get('/patients/$id');
      return Patient.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch patient');
    }
  }

  Future<Patient> createPatient(CreatePatientDto dto) async {
    try {
      final res = await _dio.post('/patients', data: dto.toJson());
      return Patient.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create patient',
      );
    }
  }

  Future<Patient> updatePatient(int id, Map<String, dynamic> updateData) async {
    try {
      final res = await _dio.patch('/patients/$id', data: updateData);
      return Patient.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update patient',
      );
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await _dio.delete('/patients/$id');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete patient',
      );
    }
  }
}
