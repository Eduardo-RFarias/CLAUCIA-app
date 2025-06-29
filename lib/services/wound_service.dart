import '../models/wound_model.dart';
import '../models/sample_model.dart';
import 'sample_service.dart';

class WoundService {
  // TODO: Remove singleton pattern when migrating to real API
  // Real API services should be stateless and instantiated normally
  // Singleton is only needed for mock data synchronization
  static final WoundService _instance = WoundService._internal();
  factory WoundService() => _instance;
  WoundService._internal();

  // Mock wound data with samples
  static final List<Wound> _mockWounds = [
    Wound(
      id: 1,
      patientId: 1, // John Smith
      location: 'Left foot (plantar surface)',
      origin: WoundOrigin.diabeticUlcers,
      description:
          'Diabetic foot ulcer on the plantar surface of the left foot, approximately 2cm in diameter',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isActive: true,
      samples: [
        Sample(
          id: 1,
          woundId: 1,
          woundPhoto: null,
          mlClassification: null, // No photo, no ML classification
          professionalClassification: WagnerClassification.grade1,
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
          woundPhoto: 'https://robohash.org/wound_sample_2?set=set5',
          mlClassification: WagnerClassification.grade0,
          professionalClassification: null,
          size: WoundSize(height: 2.3, width: 1.6),
          date: DateTime.now().subtract(const Duration(hours: 6)),
          responsibleProfessionalId: 1,
          responsibleProfessionalName: 'Dr. Ana Silva',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
    ),
    Wound(
      id: 2,
      patientId: 1, // John Smith
      location: 'Right ankle (medial malleolus)',
      origin: WoundOrigin.venousUlcers,
      description: 'Chronic venous ulcer with surrounding inflammation',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isActive: true,
      samples: [
        Sample(
          id: 3,
          woundId: 2,
          woundPhoto: 'https://robohash.org/wound_sample_3?set=set5',
          mlClassification: WagnerClassification.grade0,
          professionalClassification: WagnerClassification.grade2,
          size: null,
          date: DateTime.now().subtract(const Duration(days: 1)),
          responsibleProfessionalId: 2,
          responsibleProfessionalName: 'Dr. Carlos Santos',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ],
    ),
    Wound(
      id: 3,
      patientId: 2, // Maria Garcia
      location: 'Left shin',
      origin: WoundOrigin.nonDiabeticUlcers,
      description: 'Traumatic wound from fall, showing good healing progress',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isActive: false, // Healed
      samples: [
        Sample(
          id: 4,
          woundId: 3,
          woundPhoto: null,
          mlClassification: null, // No photo, no ML classification
          professionalClassification: WagnerClassification.grade3,
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
          woundPhoto: 'https://robohash.org/wound_sample_5?set=set5',
          mlClassification: WagnerClassification.grade0,
          professionalClassification: null,
          size: WoundSize(height: 3.8, width: 2.9),
          date: DateTime.now().subtract(const Duration(hours: 3)),
          responsibleProfessionalId: 1,
          responsibleProfessionalName: 'Dr. Ana Silva',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    Wound(
      id: 4,
      patientId: 3, // Robert Johnson
      location: 'Right foot (dorsal)',
      origin: WoundOrigin.neuropathicUlcers,
      description: 'Neuropathic ulcer on dorsal aspect of right foot',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isActive: true,
      samples: [], // No samples yet
    ),
    Wound(
      id: 5,
      patientId: 4, // Sarah Wilson
      location: 'Left leg (lateral)',
      origin: WoundOrigin.venousUlcers,
      description: 'Large venous ulcer requiring compression therapy',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isActive: true,
      samples: [
        Sample(
          id: 6,
          woundId: 5,
          woundPhoto: 'https://robohash.org/wound_sample_6?set=set5',
          mlClassification: WagnerClassification.grade0,
          professionalClassification: WagnerClassification.grade1,
          size: WoundSize(height: 5.1, width: 4.3),
          date: DateTime.now().subtract(const Duration(days: 7)),
          responsibleProfessionalId: 1,
          responsibleProfessionalName: 'Dr. Ana Silva',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    ),
    Wound(
      id: 6,
      patientId: 5, // David Brown
      location: 'Right heel',
      origin: WoundOrigin.diabeticUlcers,
      description: 'Pressure ulcer on right heel, stage 2',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now(),
      isActive: true,
      samples: [
        Sample(
          id: 7,
          woundId: 6,
          woundPhoto: null,
          mlClassification: null, // No photo, no ML classification
          professionalClassification: null, // Pending review
          size: WoundSize(height: 1.8, width: 1.5),
          date: DateTime.now().subtract(const Duration(hours: 2)),
          responsibleProfessionalId: 2,
          responsibleProfessionalName: 'Dr. Carlos Santos',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
  ];

  // Get wounds for a specific patient
  Future<List<Wound>> getWoundsByPatientId(int patientId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockWounds.where((wound) => wound.patientId == patientId).toList()
      ..sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      ); // Sort by most recent first
  }

  // Create new wound
  Future<Wound> createWound(Wound wound) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, this would be a POST request to your API
    /*
    final response = await http.post(
      Uri.parse('$baseUrl/wounds'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(wound.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Wound.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create wound');
    }
    */

    final newWound = wound.copyWith(
      id: _mockWounds.length + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockWounds.add(newWound);

    // TODO: Remove cross-service call when migrating to real API
    // API will handle wound-sample relationships automatically
    // Always create an initial sample when creating a wound
    final initialSample = Sample(
      id: 0, // Will be set by sample service
      woundId: newWound.id,
      woundPhoto: null,
      mlClassification: null,
      professionalClassification: null,
      size: null,
      date: DateTime.now(),
      responsibleProfessionalId: 1, // Mock user ID
      responsibleProfessionalName: 'Current User', // Mock user name
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    SampleService().createSample(
      woundId: newWound.id,
      woundPhoto: initialSample.woundPhoto,
      size: initialSample.size,
      professionalClassification: initialSample.professionalClassification,
    );

    return newWound;
  }

  // Update wound
  Future<Wound> updateWound(Wound wound) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));

    // In a real app, this would be a PUT request to your API
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/wounds/${wound.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(wound.toJson()),
    );
    
    if (response.statusCode == 200) {
      return Wound.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update wound');
    }
    */

    final index = _mockWounds.indexWhere((w) => w.id == wound.id);
    if (index != -1) {
      final updatedWound = wound.copyWith(updatedAt: DateTime.now());
      _mockWounds[index] = updatedWound;
      return updatedWound;
    } else {
      throw Exception('Wound not found');
    }
  }

  // TODO: Remove this method when migrating to real API
  // API will handle wound-sample relationships automatically
  // Add sample to wound (called by sample service)
  void addSampleToWound(int woundId, Sample sample) {
    final woundIndex = _mockWounds.indexWhere((w) => w.id == woundId);
    if (woundIndex != -1) {
      final wound = _mockWounds[woundIndex];
      final updatedSamples = List<Sample>.from(wound.samples)..add(sample);
      _mockWounds[woundIndex] = wound.copyWith(
        samples: updatedSamples,
        updatedAt: DateTime.now(),
      );
    }
  }

  // TODO: Remove this method when migrating to real API
  // API will handle wound-sample relationships automatically
  // Remove sample from wound (called by sample service)
  void removeSampleFromWound(int woundId, int sampleId) {
    final woundIndex = _mockWounds.indexWhere((w) => w.id == woundId);
    if (woundIndex != -1) {
      final wound = _mockWounds[woundIndex];
      final updatedSamples =
          wound.samples.where((s) => s.id != sampleId).toList();
      _mockWounds[woundIndex] = wound.copyWith(
        samples: updatedSamples,
        updatedAt: DateTime.now(),
      );
    }
  }

  // Delete wound and all its samples
  Future<void> deleteWound(int woundId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, this would be a DELETE request to your API
    /*
    final response = await http.delete(
      Uri.parse('$baseUrl/wounds/$woundId'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete wound');
    }
    */

    final woundIndex = _mockWounds.indexWhere((w) => w.id == woundId);
    if (woundIndex == -1) {
      throw Exception('Wound not found');
    }

    _mockWounds.removeAt(woundIndex);

    // TODO: Remove cross-service call when migrating to real API
    // API will handle cascading deletes automatically
    // Delete all samples associated with this wound
    final sampleService = SampleService();
    await sampleService.deleteSamplesByWoundId(woundId);
  }

  // TODO: Remove this method when migrating to real API
  // API will handle cascading deletes automatically
  // Delete all wounds for a patient (called when patient is deleted)
  Future<void> deleteWoundsByPatientId(int patientId) async {
    final patientWounds =
        _mockWounds.where((w) => w.patientId == patientId).toList();

    // Delete all samples for each wound first
    final sampleService = SampleService();
    for (final wound in patientWounds) {
      await sampleService.deleteSamplesByWoundId(wound.id);
    }

    // Remove all wounds for this patient
    _mockWounds.removeWhere((wound) => wound.patientId == patientId);
  }
}
