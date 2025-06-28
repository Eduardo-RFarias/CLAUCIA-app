import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';
import 'auth_controller.dart';
import 'app_controller.dart';

class PatientController extends GetxController {
  final PatientService _patientService = PatientService();
  final AuthController _authController = Get.find<AuthController>();
  final AppController _appController = Get.find<AppController>();

  // Observable variables
  RxList<Patient> patients = <Patient>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    fetchPatients();

    // Listen to company changes and refetch patients
    ever(_appController.selectedCompany, (_) {
      fetchPatients();
    });

    super.onInit();
  }

  // Fetch all patients
  Future<void> fetchPatients() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final currentUser = _authController.currentUser.value;
      final selectedCompany = _appController.selectedCompany.value;

      if (currentUser == null || selectedCompany.isEmpty) {
        patients.assignAll([]);
        return;
      }

      final fetchedPatients = await _patientService.getPatients(
        companyId: selectedCompany,
        userEmail: currentUser.email,
      );
      patients.assignAll(fetchedPatients);
    } catch (e) {
      hasError(true);
      errorMessage(_cleanErrorMessage(e.toString()));
      Get.snackbar(
        'Error',
        'Failed to load patients: ${errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Create new patient with individual parameters (convenience method)
  Future<Patient?> createPatient({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    String? profilePicture,
    String? medicalConditions,
  }) async {
    final patient = Patient(
      id: 0, // Will be assigned by the service
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      profilePicture: profilePicture,
      medicalConditions: medicalConditions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createPatientFromObject(patient);
  }

  // Create new patient from Patient object
  Future<Patient?> createPatientFromObject(Patient patient) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final currentUser = _authController.currentUser.value;
      final selectedCompany = _appController.selectedCompany.value;

      if (currentUser == null || selectedCompany.isEmpty) {
        throw Exception('User not authenticated or no company selected');
      }

      final newPatient = await _patientService.createPatient(
        patient,
        companyId: selectedCompany,
        userEmail: currentUser.email,
      );

      // Add to the beginning of the list (most recent)
      patients.insert(0, newPatient);

      Get.snackbar(
        'Success',
        'Patient ${newPatient.name} created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return newPatient;
    } catch (e) {
      hasError(true);
      errorMessage(_cleanErrorMessage(e.toString()));
      Get.snackbar(
        'Error',
        'Failed to create patient: ${errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading(false);
    }
  }

  // Helper method to clean error messages
  String _cleanErrorMessage(String error) {
    return error.replaceAll('Exception: ', '');
  }
}

  // Search patients by name
  List<Patient> searchPatients(String query) {
    if (query.isEmpty) return patients;

    return patients.where((patient) {
      return patient.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get patients count
  int get patientsCount => patients.length;

  // Get patients by gender
  List<Patient> getPatientsByGender(String gender) {
    return patients
        .where(
          (patient) => patient.gender.toLowerCase() == gender.toLowerCase(),
        )
        .toList();
  }

  // Get patients with medical conditions
  List<Patient> getPatientsWithConditions() {
    return patients
        .where(
          (patient) =>
              patient.medicalConditions != null &&
              patient.medicalConditions!.isNotEmpty,
        )
        .toList();
  }
}
