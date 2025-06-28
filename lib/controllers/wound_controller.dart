import 'package:get/get.dart';
import '../models/wound_model.dart';
import '../services/wound_service.dart';

class WoundController extends GetxController {
  final WoundService _woundService = WoundService();

  // Observable lists and states
  var wounds = <Wound>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  // Load wounds for a specific patient
  Future<void> loadWoundsByPatientId(int patientId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final woundList = await _woundService.getWoundsByPatientId(patientId);
      wounds.value = woundList;
    } catch (e) {
      error.value = 'Failed to load wounds: $e';
      Get.snackbar(
        'Error',
        'Failed to load wounds: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get active wounds count for a patient
  Future<int> getActiveWoundsCount(int patientId) async {
    try {
      return await _woundService.getWoundsCountByPatientId(patientId);
    } catch (e) {
      return 0;
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
      error.value = 'Failed to create wound: $e';
      Get.snackbar(
        'Error',
        'Failed to create wound: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Update wound
  Future<void> updateWound(Wound wound) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedWound = await _woundService.updateWound(wound);
      final index = wounds.indexWhere((w) => w.id == wound.id);
      if (index != -1) {
        wounds[index] = updatedWound;
        wounds.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }

      Get.snackbar(
        'Success',
        'Wound updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to update wound: $e';
      Get.snackbar(
        'Error',
        'Failed to update wound: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get wound by ID
  Future<Wound?> getWoundById(int id) async {
    try {
      return await _woundService.getWoundById(id);
    } catch (e) {
      error.value = 'Failed to get wound: $e';
      return null;
    }
  }

  // Utility methods
  List<Wound> get activeWounds =>
      wounds.where((wound) => wound.isActive).toList();
  List<Wound> get healedWounds =>
      wounds.where((wound) => !wound.isActive).toList();

  int get activeWoundsCount => activeWounds.length;
  int get healedWoundsCount => healedWounds.length;
  int get totalWoundsCount => wounds.length;
}
