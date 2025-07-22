import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../dtos/create_patient_dto.dart';
import '../services/patient_service.dart';
import '../services/localization_service.dart';
import 'app_controller.dart';

class PatientController extends GetxController {
  final PatientService _patientService = PatientService();
  final AppController _appController = Get.find<AppController>();

  // Observable variables
  final RxList<Patient> patients = <Patient>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchByInstitution();
    ever(_appController.selectedInstitution, (_) => _fetchByInstitution());
  }

  Future<void> _fetchByInstitution() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (_appController.selectedInstitution.value.isEmpty) {
        patients.clear();
        return;
      }
      final fetched = await _patientService.getPatientsByInstitution(
        _appController.selectedInstitution.value,
      );
      patients.assignAll(fetched);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = _cleanErrorMessage(e.toString());
      Get.snackbar(
        l10n.error,
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Public wrapper so UI can refresh the patient list.
  Future<void> fetchPatients() => _fetchByInstitution();

  Future<Patient?> createPatient(CreatePatientDto dto) async {
    try {
      isLoading.value = true;
      final created = await _patientService.createPatient(dto);
      patients.insert(0, created);
      return created;
    } catch (e) {
      Get.snackbar(
        l10n.error,
        _cleanErrorMessage(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await _patientService.deletePatient(id);
      patients.removeWhere((p) => p.id == id);
    } catch (e) {
      Get.snackbar(
        l10n.error,
        _cleanErrorMessage(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Convenience filters
  List<Patient> get malePatients =>
      patients.where((p) => p.sex == Sex.male).toList();
  List<Patient> get femalePatients =>
      patients.where((p) => p.sex == Sex.female).toList();
  int get patientsCount => patients.length;

  String _cleanErrorMessage(String error) =>
      error.replaceAll('Exception: ', '');
}
