// import 'package:dio/dio.dart'; // Commented out for mock implementation
import '../models/patient_model.dart';
import '../services/wound_service.dart';

class PatientService {
  // Commented out for mock implementation - will be used in real API implementation
  // final Dio _dio = Dio();
  // final String _baseUrl = 'https://medical-api.example.com'; // Mock URL

  // Mock patients data with company and assigned doctor associations
  final List<Map<String, dynamic>> _mockPatients = [
    // Acme Corporation patients
    {
      'id': 1,
      'name': 'Alice Johnson',
      'dateOfBirth': '1985-03-15T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-01-15T08:30:00.000Z',
      'updatedAt': '2024-12-20T14:22:00.000Z',
      'gender': 'Female',
      'medicalConditions': 'Hypertension, Diabetes Type 2',
      'companyId': 'Acme Corporation',
      'assignedDoctorEmail': 'john@example.com',
    },
    {
      'id': 2,
      'name': 'Robert Smith',
      'dateOfBirth': '1978-07-22T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-02-10T10:15:00.000Z',
      'updatedAt': '2024-12-19T16:45:00.000Z',
      'gender': 'Male',
      'medicalConditions': 'Asthma',
      'companyId': 'Acme Corporation',
      'assignedDoctorEmail': 'jane@example.com',
    },
    {
      'id': 3,
      'name': 'Maria Garcia',
      'dateOfBirth': '1992-11-08T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-03-05T14:20:00.000Z',
      'updatedAt': '2024-12-18T11:30:00.000Z',
      'gender': 'Female',
      'medicalConditions': null,
      'companyId': 'TechFlow Solutions',
      'assignedDoctorEmail': 'john@example.com',
    },
    {
      'id': 4,
      'name': 'James Wilson',
      'dateOfBirth': '1965-05-30T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-01-20T09:45:00.000Z',
      'updatedAt': '2024-12-17T13:15:00.000Z',
      'gender': 'Male',
      'medicalConditions': 'High Cholesterol, Arthritis',
      'companyId': 'TechFlow Solutions',
      'assignedDoctorEmail': 'test@test.com',
    },
    {
      'id': 5,
      'name': 'Emily Davis',
      'dateOfBirth': '1988-09-12T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-02-28T11:30:00.000Z',
      'updatedAt': '2024-12-16T09:20:00.000Z',
      'gender': 'Female',
      'medicalConditions': 'Allergies (Penicillin)',
      'companyId': 'Global Industries',
      'assignedDoctorEmail': 'jane@example.com',
    },
    {
      'id': 6,
      'name': 'Michael Brown',
      'dateOfBirth': '1995-12-03T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-03-10T15:45:00.000Z',
      'updatedAt': '2024-12-15T10:05:00.000Z',
      'gender': 'Male',
      'medicalConditions': null,
      'companyId': 'Global Industries',
      'assignedDoctorEmail': 'john@example.com',
    },
    {
      'id': 7,
      'name': 'Sarah Williams',
      'dateOfBirth': '1982-04-18T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-01-25T12:00:00.000Z',
      'updatedAt': '2024-12-14T14:40:00.000Z',
      'gender': 'Female',
      'medicalConditions': 'Thyroid Disorder',
      'companyId': 'InnovateCorp',
      'assignedDoctorEmail': 'test@test.com',
    },
    {
      'id': 8,
      'name': 'David Miller',
      'dateOfBirth': '1975-11-14T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-01-08T16:20:00.000Z',
      'updatedAt': '2024-12-13T12:30:00.000Z',
      'gender': 'Male',
      'medicalConditions': 'Chronic Back Pain',
      'companyId': 'InnovateCorp',
      'assignedDoctorEmail': 'jane@example.com',
    },
    {
      'id': 9,
      'name': 'Lisa Anderson',
      'dateOfBirth': '1990-06-22T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-02-14T09:15:00.000Z',
      'updatedAt': '2024-12-12T15:45:00.000Z',
      'gender': 'Female',
      'medicalConditions': null,
      'companyId': 'NextGen Systems',
      'assignedDoctorEmail': 'john@example.com',
    },
    {
      'id': 10,
      'name': 'Thomas Johnson',
      'dateOfBirth': '1983-08-30T00:00:00.000Z',
      'profilePicture': null,
      'createdAt': '2024-03-18T13:40:00.000Z',
      'updatedAt': '2024-12-11T11:20:00.000Z',
      'gender': 'Male',
      'medicalConditions': 'Insomnia, Anxiety',
      'companyId': 'Digital Dynamics',
      'assignedDoctorEmail': 'test@test.com',
    },
  ];

  Future<List<Patient>> getPatients({
    required String companyId,
    required String userEmail,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Filter patients by company and assigned doctor
      final filteredPatients =
          _mockPatients.where((patient) {
            return patient['companyId'] == companyId &&
                patient['assignedDoctorEmail'] == userEmail;
          }).toList();

      // Sort by updatedAt in descending order (most recent first)
      filteredPatients.sort((a, b) {
        final dateA = DateTime.parse(a['updatedAt']);
        final dateB = DateTime.parse(b['updatedAt']);
        return dateB.compareTo(dateA);
      });

      return filteredPatients.map((json) => Patient.fromJson(json)).toList();

      // In real implementation, this would be:
      /*
      final response = await _dio.get(
        '$_baseUrl/patients',
        queryParameters: {
          'companyId': companyId,
          'assignedDoctorEmail': userEmail,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load patients');
      }
      */
    } catch (e) {
      throw Exception('Error fetching patients: $e');
    }
  }

  Future<Patient> getPatientById(int id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final patientData = _mockPatients.firstWhere(
        (patient) => patient['id'] == id,
        orElse: () => throw Exception('Patient not found'),
      );

      return Patient.fromJson(patientData);

      // In real implementation, this would be:
      /*
      final response = await _dio.get('$_baseUrl/patients/$id');
      
      if (response.statusCode == 200) {
        return Patient.fromJson(response.data);
      } else {
        throw Exception('Failed to load patient with ID: $id');
      }
      */
    } catch (e) {
      throw Exception('Error fetching patient with ID $id: $e');
    }
  }

  Future<Patient> createPatient(
    Patient patient, {
    required String companyId,
    required String userEmail,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate a new ID
      final newId =
          _mockPatients.isNotEmpty
              ? _mockPatients
                      .map((p) => p['id'] as int)
                      .reduce((a, b) => a > b ? a : b) +
                  1
              : 1;

      final now = DateTime.now();
      final newPatient = patient.copyWith(
        id: newId,
        createdAt: now,
        updatedAt: now,
      );

      // Add company and user assignment to the patient data
      final patientJson = newPatient.toJson();
      patientJson['companyId'] = companyId;
      patientJson['assignedDoctorEmail'] = userEmail;

      // Add to mock data
      _mockPatients.add(patientJson);

      return newPatient;

      // In real implementation, this would be:
      /*
      final response = await _dio.post(
        '$_baseUrl/patients',
        data: patient.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Patient.fromJson(response.data);
      } else {
        throw Exception('Failed to create patient');
      }
      */
    } catch (e) {
      throw Exception('Error creating patient: $e');
    }
  }

  Future<Patient> updatePatient(Patient patient) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final index = _mockPatients.indexWhere((p) => p['id'] == patient.id);
      if (index == -1) {
        throw Exception('Patient not found');
      }

      final updatedPatient = patient.copyWith(updatedAt: DateTime.now());
      _mockPatients[index] = updatedPatient.toJson();

      return updatedPatient;

      // In real implementation, this would be:
      /*
      final response = await _dio.put(
        '$_baseUrl/patients/${patient.id}',
        data: patient.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Patient.fromJson(response.data);
      } else {
        throw Exception('Failed to update patient');
      }
      */
    } catch (e) {
      throw Exception('Error updating patient: $e');
    }
  }

  // Delete patient and all associated wounds and samples
  Future<void> deletePatient(int patientId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would be a DELETE request to your API
      /*
      final response = await http.delete(
        Uri.parse('$baseUrl/patients/$patientId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete patient');
      }
      */

      final patientIndex = _mockPatients.indexWhere(
        (p) => p['id'] == patientId,
      );
      if (patientIndex == -1) {
        throw Exception('Patient not found');
      }

      _mockPatients.removeAt(patientIndex);

      // TODO: Remove cross-service calls when migrating to real API
      // API will handle cascading deletes automatically
      // Delete all wounds and samples associated with this patient
      final woundService = WoundService();
      await woundService.deleteWoundsByPatientId(patientId);
    } catch (e) {
      throw Exception('Error deleting patient: $e');
    }
  }
}
