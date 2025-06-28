import 'package:get/get.dart';
import '../models/sample_model.dart';
import '../controllers/auth_controller.dart';
import 'wound_service.dart';

class SampleService {
  // TODO: Remove singleton pattern when migrating to real API
  // Real API services should be stateless and instantiated normally
  // Singleton is only needed for mock data synchronization
  static final SampleService _instance = SampleService._internal();
  factory SampleService() => _instance;
  SampleService._internal();

  // ML Classification Logic:
  // - When creating a sample with a photo, ML inference runs automatically
  // - The mock ML inference always returns Grade 0 after a 2-second delay
  // - Samples without photos have null ML classification
  // - Professional classification is independent and set by doctors

  // Mock data for samples
  static final List<Sample> _mockSamples = [
    Sample(
      id: 1,
      woundId: 1,
      woundPhoto: null, // No photo for this sample
      mlClassification: null, // No photo, no ML classification
      professionalClassification:
          WagnerClassification.grade1, // Professional reviewed and changed
      size: WoundSize(height: 2.5, width: 1.8),
      date: DateTime.now().subtract(const Duration(days: 2)),
      responsibleProfessionalId: 1,
      responsibleProfessionalName: 'Dr. Ana Silva',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Sample(
      id: 2,
      woundId: 1,
      woundPhoto: 'assets/images/sample_photo_2.jpg', // Mock photo path
      mlClassification:
          WagnerClassification
              .grade0, // Photo provided, ML classification available
      professionalClassification: null, // Not reviewed yet
      size: WoundSize(height: 2.3, width: 1.6),
      date: DateTime.now().subtract(const Duration(hours: 6)),
      responsibleProfessionalId: 1,
      responsibleProfessionalName: 'Dr. Ana Silva',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Sample(
      id: 3,
      woundId: 2,
      woundPhoto: 'assets/images/sample_photo_3.jpg',
      mlClassification:
          WagnerClassification.grade0, // Mock ML always returns Grade 0
      professionalClassification:
          WagnerClassification.grade2, // Professional classified as Grade 2
      size: null, // No size measurements
      date: DateTime.now().subtract(const Duration(days: 1)),
      responsibleProfessionalId: 2,
      responsibleProfessionalName: 'Dr. Carlos Santos',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Sample(
      id: 4,
      woundId: 3,
      woundPhoto: null,
      mlClassification: null, // No photo, no ML classification
      professionalClassification:
          WagnerClassification.grade3, // Professional classified as Grade 3
      size: WoundSize(height: 4.2, width: 3.1),
      date: DateTime.now().subtract(const Duration(days: 3)),
      responsibleProfessionalId: 1,
      responsibleProfessionalName: 'Dr. Ana Silva',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Sample(
      id: 5,
      woundId: 3,
      woundPhoto: 'assets/images/sample_photo_5.jpg',
      mlClassification:
          WagnerClassification.grade0, // Mock ML always returns Grade 0
      professionalClassification: null, // Not reviewed yet
      size: WoundSize(height: 3.8, width: 2.9),
      date: DateTime.now().subtract(const Duration(hours: 3)),
      responsibleProfessionalId: 1,
      responsibleProfessionalName: 'Dr. Ana Silva',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // Get samples by wound ID
  Future<List<Sample>> getSamplesByWoundId(int woundId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter samples by wound ID and sort by date (newest first)
    final samples =
        _mockSamples.where((sample) => sample.woundId == woundId).toList();

    samples.sort((a, b) => b.date.compareTo(a.date));

    return samples;
  }

  // Create a new sample
  Future<Sample> createSample({
    required int woundId,
    String? woundPhoto,
    WoundSize? size,
    WagnerClassification? professionalClassification,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Run ML classification if photo is provided
    WagnerClassification? mlClassification;
    if (woundPhoto != null) {
      mlClassification = await classifyWoundWithML(woundPhoto);
    }

    final newSample = Sample(
      id: _mockSamples.length + 1,
      woundId: woundId,
      woundPhoto: woundPhoto,
      mlClassification: mlClassification,
      professionalClassification: professionalClassification,
      size: size,
      date: DateTime.now(),
      responsibleProfessionalId: user.id,
      responsibleProfessionalName: user.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockSamples.add(newSample);

    // TODO: Remove cross-service call when migrating to real API
    // API will handle wound-sample relationships automatically
    WoundService().addSampleToWound(woundId, newSample);

    return newSample;
  }

  // Update sample professional classification
  Future<Sample> updateSampleClassification({
    required int sampleId,
    required WagnerClassification professionalClassification,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final sampleIndex = _mockSamples.indexWhere((s) => s.id == sampleId);
    if (sampleIndex == -1) {
      throw Exception('Sample not found');
    }

    final updatedSample = _mockSamples[sampleIndex].copyWith(
      professionalClassification: professionalClassification,
      updatedAt: DateTime.now(),
    );

    _mockSamples[sampleIndex] = updatedSample;
    return updatedSample;
  }

  // Delete sample
  Future<void> deleteSample(int sampleId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // In a real app, this would be a DELETE request to your API
    /*
    final response = await http.delete(
      Uri.parse('$baseUrl/samples/$sampleId'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete sample');
    }
    */

    final sampleIndex = _mockSamples.indexWhere((s) => s.id == sampleId);
    if (sampleIndex == -1) {
      throw Exception('Sample not found');
    }

    final sample = _mockSamples[sampleIndex];
    _mockSamples.removeAt(sampleIndex);

    // TODO: Remove cross-service call when migrating to real API
    // API will handle wound-sample relationships automatically
    WoundService().removeSampleFromWound(sample.woundId, sampleId);
  }

  // TODO: Remove this method when migrating to real API
  // API will handle cascading deletes automatically
  // Delete all samples for a wound (called when wound is deleted)
  Future<void> deleteSamplesByWoundId(int woundId) async {
    _mockSamples.removeWhere((sample) => sample.woundId == woundId);
  }

  // Mock ML classification (always returns Grade 0)
  Future<WagnerClassification> classifyWoundWithML(String imagePath) async {
    // Simulate ML processing time
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Replace with real ML inference
    // In a real implementation, this would:
    // 1. Load the ML model
    // 2. Preprocess the image (resize, normalize, etc.)
    // 3. Run inference
    // 4. Post-process the results
    // 5. Return the classification

    // Mock: always return Grade 0 for now
    return WagnerClassification.grade0;
  }
}
