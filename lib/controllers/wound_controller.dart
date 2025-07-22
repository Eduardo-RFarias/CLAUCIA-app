import 'package:get/get.dart';
import '../models/wound_model.dart';
import '../dtos/create_wound_dto.dart';
import '../services/wound_service.dart';
import '../services/localization_service.dart';

class WoundController extends GetxController {
  final WoundService _woundService = WoundService();

  final RxList<Wound> wounds = <Wound>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadWoundsByPatient(int patientId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final list = await _woundService.getWoundsByPatient(patientId);
      wounds.assignAll(list);
    } catch (e) {
      error.value = _clean(e.toString());
      Get.snackbar(
        l10n.error,
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Wound?> createWound(CreateWoundDto dto) async {
    try {
      isLoading.value = true;
      final created = await _woundService.createWound(dto);
      wounds.insert(0, created);
      return created;
    } catch (e) {
      error.value = _clean(e.toString());
      Get.snackbar(
        l10n.error,
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteWound(int id) async {
    try {
      await _woundService.deleteWound(id);
      wounds.removeWhere((w) => w.id == id);
    } catch (e) {
      error.value = _clean(e.toString());
      Get.snackbar(
        l10n.error,
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  int get woundsCount => wounds.length;

  String _clean(String e) => e.replaceAll('Exception: ', '');
}
