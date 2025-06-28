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

  // Single patient variables
  Rx<Patient?> currentPatient = Rx<Patient?>(null);
  RxBool isLoadingPatient = false.obs;
  RxBool hasPatientError = false.obs;
  RxString patientErrorMessage = ''.obs;

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
      errorMessage(e.toString().replaceAll('Exception: ', ''));
      Get.snackbar(
        'Error',
        'Failed to load patients: ${errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Fetch patient by ID
  Future<void> fetchPatientById(int id) async {
    try {
      isLoadingPatient(true);
      hasPatientError(false);
      patientErrorMessage('');

      final fetchedPatient = await _patientService.getPatientById(id);
      currentPatient.value = fetchedPatient;

      // Update patient in the list if it exists
      final index = patients.indexWhere((patient) => patient.id == id);
      if (index != -1) {
        patients[index] = fetchedPatient;
      }
    } catch (e) {
      hasPatientError(true);
      patientErrorMessage(e.toString().replaceAll('Exception: ', ''));
      Get.snackbar(
        'Error',
        'Failed to load patient: ${patientErrorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingPatient(false);
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
      errorMessage(e.toString().replaceAll('Exception: ', ''));
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

  // Update patient
  Future<void> updatePatient(Patient patient) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final updatedPatient = await _patientService.updatePatient(patient);

      // Update in the list
      final index = patients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        patients[index] = updatedPatient;
        // Move to top since it was updated
        patients.removeAt(index);
        patients.insert(0, updatedPatient);
      }

      // Update current patient if it's the same
      if (currentPatient.value?.id == patient.id) {
        currentPatient.value = updatedPatient;
      }

      Get.snackbar(
        'Success',
        'Patient ${updatedPatient.name} updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      hasError(true);
      errorMessage(e.toString().replaceAll('Exception: ', ''));
      Get.snackbar(
        'Error',
        'Failed to update patient: ${errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Delete patient
  Future<void> deletePatient(int id) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      await _patientService.deletePatient(id);

      // Remove from the list
      patients.removeWhere((patient) => patient.id == id);

      // Clear current patient if it was deleted
      if (currentPatient.value?.id == id) {
        currentPatient.value = null;
      }

      Get.snackbar(
        'Success',
        'Patient deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      hasError(true);
      errorMessage(e.toString().replaceAll('Exception: ', ''));
      Get.snackbar(
        'Error',
        'Failed to delete patient: ${errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Clear error messages
  void clearError() {
    hasError(false);
    errorMessage('');
    hasPatientError(false);
    patientErrorMessage('');
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
