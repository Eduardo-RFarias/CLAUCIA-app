import 'package:get/get.dart';
import '../models/sample_model.dart';
import '../dtos/create_sample_dto.dart';
import '../services/sample_service.dart';
import '../services/localization_service.dart';

class SampleController extends GetxController {
  final SampleService _sampleService = SampleService();

  final RxList<Sample> samples = <Sample>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isWorking = false.obs;
  final RxString error = ''.obs;

  Future<void> loadSamplesByWound(int woundId) async {
    try {
      isLoading.value = true;
      samples.assignAll(await _sampleService.getSamplesByWound(woundId));
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

  Future<Sample?> createSample(CreateSampleDto dto) async {
    try {
      isWorking.value = true;
      final created = await _sampleService.createSample(dto);
      samples.insert(0, created);
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
      isWorking.value = false;
    }
  }

  Future<void> updateSample(int id, Map<String, dynamic> data) async {
    try {
      isWorking.value = true;
      final updated = await _sampleService.updateSample(id, data);
      final idx = samples.indexWhere((s) => s.id == id);
      if (idx != -1) samples[idx] = updated;
    } catch (e) {
      error.value = _clean(e.toString());
      Get.snackbar(
        l10n.error,
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isWorking.value = false;
    }
  }

  Future<void> deleteSample(int id) async {
    try {
      isWorking.value = true;
      await _sampleService.deleteSample(id);
      samples.removeWhere((s) => s.id == id);
    } catch (e) {
      error.value = _clean(e.toString());
      Get.snackbar(
        l10n.error,
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isWorking.value = false;
    }
  }

  String _clean(String e) => e.replaceAll('Exception: ', '');
}
