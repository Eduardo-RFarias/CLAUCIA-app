import 'package:get/get.dart';
import '../models/wound_model.dart';
import '../services/wound_service.dart';

class WoundController extends GetxController {
  final WoundService _woundService = WoundService();

  // Observable lists and states
  final RxList<Wound> wounds = <Wound>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Load wounds for a specific patient
  Future<void> loadWoundsByPatientId(int patientId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final woundList = await _woundService.getWoundsByPatientId(patientId);
      wounds.value = woundList;
    } catch (e) {
      error.value = _cleanErrorMessage(e.toString());
      Get.snackbar(
        'Error',
        'Failed to load wounds: ${error.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create new wound
  Future<Wound?> createWound(Wound wound) async {
    try {
      isLoading.value = true;
      error.value = '';

      final newWound = await _woundService.createWound(wound);
      wounds.add(newWound);
      wounds.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      Get.snackbar(
        'Success',
        'Wound created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return newWound;
    } catch (e) {
      error.value = _cleanErrorMessage(e.toString());
      Get.snackbar(
        'Error',
        'Failed to create wound: ${error.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // GetX Reactive Utility Methods (for UI state management)
  List<Wound> get activeWounds =>
      wounds.where((wound) => wound.isActive).toList();

  List<Wound> get healedWounds =>
      wounds.where((wound) => !wound.isActive).toList();

  int get activeWoundsCount => activeWounds.length;
  int get healedWoundsCount => healedWounds.length;
  int get totalWoundsCount => wounds.length;

  // Get wound by ID (useful for navigation state)
  Wound? getWoundById(int id) {
    try {
      return wounds.firstWhere((wound) => wound.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to clean error messages
  String _cleanErrorMessage(String error) {
    return error.replaceAll('Exception: ', '');
  }
}
