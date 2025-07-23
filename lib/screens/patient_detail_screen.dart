import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../models/patient_model.dart';
import '../models/wound_model.dart';
import '../controllers/wound_controller.dart';
import '../controllers/sample_controller.dart';
import '../controllers/patient_controller.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';
import 'create_wound_screen.dart';
import 'wound_detail_screen.dart';
import '../services/patient_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final WoundController woundController = Get.put(WoundController());
  final SampleController sampleController = Get.put(SampleController());
  final PatientController patientController = Get.find<PatientController>();

  final PatientService _patientService = PatientService();

  Patient? _patient;
  bool _isLoadingPatient = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    try {
      final p = await _patientService.getPatient(widget.patientId);
      setState(() {
        _patient = p;
        _isLoadingPatient = false;
      });
      await woundController.loadWoundsByPatient(p.id);

      // After wounds are loaded, fetch samples for each wound once.
      for (final w in woundController.wounds) {
        await sampleController.loadSamplesByWound(w.id);
      }
    } catch (_) {
      setState(() => _isLoadingPatient = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPatient) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.error)),
        body: Center(child: Text(context.l10n.noUserDataAvailable)),
      );
    }

    final patient = _patient!;
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(patient);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Header
            Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture
                  _buildPatientAvatar(patient, 60),
                  const SizedBox(height: 16),

                  // Patient Name
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Age and Gender
                  Text(
                    '${patient.ageString} • ${patient.sex.localizedValue}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Patient Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.basicInformation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.cake,
                            context.l10n.dateOfBirth,
                            patient.dateOfBirth.formattedDate,
                          ),
                          const SizedBox(height: 12),

                          _buildInfoRow(
                            Icons.wc,
                            context.l10n.biologicSex,
                            patient.sex.localizedValue,
                          ),
                          const SizedBox(height: 12),

                          _buildInfoRow(
                            Icons.calendar_today,
                            context.l10n.age,
                            patient.ageString,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medical Conditions Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.medicalConditions,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (patient.medicalConditions != null &&
                              patient.medicalConditions!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                patient.medicalConditions!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            )
                          else
                            Text(
                              context.l10n.noMedicalConditionsRecorded,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wounds Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.wounds,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => CreateWoundScreen(
                                      patientId: patient.id,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(context.l10n.addWound),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Wounds list
                          Obx(() {
                            if (woundController.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (woundController.wounds.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.healing,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      context.l10n.noWoundsRecorded,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      context.l10n.woundsProgressMessage,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: woundController.wounds.length,
                              separatorBuilder:
                                  (context, index) =>
                                      const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final wound = woundController.wounds[index];
                                return _buildWoundCard(wound);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Patient History Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.patientHistory,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.person_add,
                            context.l10n.created,
                            patient.createdAt.formattedDateTimeWithTimezone,
                          ),
                          const SizedBox(height: 12),

                          _buildInfoRow(
                            Icons.update,
                            context.l10n.lastUpdated,
                            patient.updatedAt.formattedDateTimeWithTimezone,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWoundCard(Wound wound) {
    const Color uiColor = Colors.blue;
    // Fetch samples corresponding to this wound from SampleController
    final woundSamples =
        sampleController.samples.where((s) => s.woundId == wound.id).toList();

    final latestSample =
        woundSamples.isNotEmpty
            ? woundSamples.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
            : null;

    return InkWell(
      onTap: () {
        Get.to(() => WoundDetailScreen(woundId: wound.id));
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wound header
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: uiColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Location
                  Expanded(
                    child: Text(
                      wound.location,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: uiColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: uiColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      wound.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: uiColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Origin
              Text(
                wound.origin.localizedDisplayName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (wound.description != null &&
                  wound.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  wound.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Sample information section
              if (latestSample != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.latestSample,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            latestSample.timeSinceCreation,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Wagner classification
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  (latestSample.aiClassification != null ||
                                          latestSample
                                                  .professionalClassification !=
                                              null)
                                      ? latestSample
                                          .effectiveClassification
                                          .color
                                      : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              (latestSample.aiClassification != null ||
                                      latestSample.professionalClassification !=
                                          null)
                                  ? latestSample
                                      .effectiveClassification
                                      .localizedDescription
                                  : context.l10n.pendingAssessment,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    (latestSample.aiClassification != null ||
                                            latestSample
                                                    .professionalClassification !=
                                                null)
                                        ? latestSample
                                            .effectiveClassification
                                            .color
                                        : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          if (latestSample.hasBeenReviewed)
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.green.shade600,
                            )
                          else
                            Icon(
                              Icons.pending,
                              size: 14,
                              color: Colors.orange.shade600,
                            ),
                        ],
                      ),

                      // Size information if available
                      if (latestSample.height != null &&
                          latestSample.width != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.straighten,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${context.l10n.size}: ${latestSample.height!.toStringAsFixed(1)} x ${latestSample.width!.toStringAsFixed(1)} cm',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Samples count
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${woundSamples.length} ${context.l10n.sample}${woundSamples.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (woundSamples.any((s) => !s.hasBeenReviewed)) ...[
                      Icon(
                        Icons.pending_actions,
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${woundSamples.where((s) => !s.hasBeenReviewed).length} ${context.l10n.pendingReview}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                // No samples
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.noSamplesRecorded,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Date row
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${context.l10n.createdTime} ${wound.daysSinceCreation}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Patient patient) {
    Get.dialog(
      AlertDialog(
        title: Text(context.l10n.deletePatient),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.areYouSureDeletePatient),
            const SizedBox(height: 8),
            Text(
              patient.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final woundsCount = woundController.wounds.length;
              final samplesCount = sampleController.samples.length;

              return Text(
                context.l10n.deleteWoundsAndSamples(woundsCount, samplesCount),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              context.l10n.actionCannotBeUndone,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(context.l10n.cancel),
          ),
          Obx(
            () => ElevatedButton(
              onPressed:
                  patientController.isLoading.value ? null : _deletePatient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child:
                  patientController.isLoading.value
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(context.l10n.delete),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePatient() async {
    // Extract localized strings before async gap
    final successTitle = context.l10n.success;
    final successMessage = context.l10n.patientDeletedSuccessfully(
      _patient!.name,
    );
    final errorTitle = context.l10n.error;
    final errorMessage = context.l10n.failedToDeletePatient;

    try {
      await patientController.deletePatient(_patient!.id);

      // Close confirmation dialog first
      Get.back();

      // Then navigate back to the previous screen
      Get.back();

      // Show success message after navigation
      Get.snackbar(
        successTitle,
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Close confirmation dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        errorTitle,
        '$errorMessage: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Decode Base-64 image (raw or data URI) to MemoryImage, else null.
  ImageProvider? _localImageProvider(String src) {
    final base64Part =
        src.startsWith('data:image/') ? src.split(',').last : src;
    try {
      final bytes = base64Decode(base64Part);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Build patient avatar with proper error handling for network images
  Widget _buildPatientAvatar(Patient patient, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade100,
      ),
      child: ClipOval(
        child:
            (patient.photo != null && patient.photo!.isNotEmpty)
                ? ((patient.photo!.startsWith('http') ||
                        patient.photo!.startsWith('/'))
                    ? CachedNetworkImage(
                      imageUrl: patient.photoUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.blue.shade100,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade600,
                                ),
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) =>
                              _buildPatientInitials(patient, radius),
                    )
                    : _buildLocalPatientImage(patient, radius))
                : _buildPatientInitials(patient, radius),
      ),
    );
  }

  /// Build patient initials avatar
  Widget _buildPatientInitials(Patient patient, double radius) {
    return Container(
      color: Colors.blue.shade100,
      child: Center(
        child: Text(
          patient.initials,
          style: TextStyle(
            fontSize: radius * 0.5, // Scale font size with radius
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ),
    );
  }

  /// Build patient avatar from local image with error handling
  Widget _buildLocalPatientImage(Patient patient, double radius) {
    final imageProvider = _localImageProvider(patient.photo!);
    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
                _buildPatientInitials(patient, radius),
      );
    } else {
      return _buildPatientInitials(patient, radius);
    }
  }
}
