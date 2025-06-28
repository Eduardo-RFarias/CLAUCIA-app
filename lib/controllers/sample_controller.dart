import 'package:get/get.dart';
import '../models/sample_model.dart';
import '../services/sample_service.dart';

class SampleController extends GetxController {
  final SampleService _sampleService = SampleService();

  // Observable list of samples
  final RxList<Sample> samples = <Sample>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;

  // Error handling
  final RxString error = ''.obs;

  // Load samples by wound ID
  Future<void> loadSamplesByWoundId(int woundId) async {
    try {
      error.value = '';
      isLoading.value = true;

      final fetchedSamples = await _sampleService.getSamplesByWoundId(woundId);
      samples.value = fetchedSamples;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load samples: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new sample
  Future<void> createSample({
    required int woundId,
    String? woundPhoto,
    WoundSize? size,
    WagnerClassification? professionalClassification,
    bool showSnackbar = true,
  }) async {
    try {
      error.value = '';
      isCreating.value = true;

      final newSample = await _sampleService.createSample(
        woundId: woundId,
        woundPhoto: woundPhoto,
        size: size,
        professionalClassification: professionalClassification,
      );

      // Add the new sample to the list and sort by date
      samples.add(newSample);
      samples.sort((a, b) => b.date.compareTo(a.date));

      if (showSnackbar) {
        Get.snackbar(
          'Success',
          'Sample created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to create sample: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreating.value = false;
    }
  }

  // Update sample professional classification
  Future<void> updateSampleClassification({
    required int sampleId,
    required WagnerClassification professionalClassification,
  }) async {
    try {
      error.value = '';
      isUpdating.value = true;

      final updatedSample = await _sampleService.updateSampleClassification(
        sampleId: sampleId,
        professionalClassification: professionalClassification,
      );

      // Update the sample in the list
      final index = samples.indexWhere((s) => s.id == sampleId);
      if (index != -1) {
        samples[index] = updatedSample;
      }

      Get.snackbar(
        'Success',
        'Sample classification updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update sample: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // Get sample by ID
  Sample? getSampleById(int sampleId) {
    try {
      return samples.firstWhere((sample) => sample.id == sampleId);
    } catch (e) {
      return null;
    }
  }

  // Get samples for a specific wound
  List<Sample> getSamplesForWound(int woundId) {
    return samples.where((sample) => sample.woundId == woundId).toList();
  }

  // Get the latest sample for a wound
  Sample? getLatestSampleForWound(int woundId) {
    final woundSamples = getSamplesForWound(woundId);
    if (woundSamples.isEmpty) return null;

    woundSamples.sort((a, b) => b.date.compareTo(a.date));
    return woundSamples.first;
  }

  // Refresh samples for current wound
  Future<void> refreshSamples(int woundId) async {
    await loadSamplesByWoundId(woundId);
  }

  // Get reviewed samples count
  int get reviewedSamplesCount {
    return samples.where((sample) => sample.hasBeenReviewed).length;
  }

  // Get pending review samples count
  int get pendingReviewSamplesCount {
    return samples.where((sample) => !sample.hasBeenReviewed).length;
  }

  // Mock ML classification
  Future<WagnerClassification> classifyWoundWithML(String imagePath) async {
    return await _sampleService.classifyWoundWithML(imagePath);
  }
}
