import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/sample_model.dart';
import '../models/wound_model.dart';
import '../controllers/sample_controller.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';
import '../services/sample_service.dart'; // Added for updateSample
import '../utils/image_utils.dart';

class SampleDetailScreen extends StatefulWidget {
  final Sample sample;
  final Wound? wound; // Optional wound info for context

  const SampleDetailScreen({super.key, required this.sample, this.wound});

  @override
  State<SampleDetailScreen> createState() => _SampleDetailScreenState();
}

class _SampleDetailScreenState extends State<SampleDetailScreen> {
  final SampleController sampleController = Get.find<SampleController>();
  late Sample currentSample;

  @override
  void initState() {
    super.initState();
    currentSample = widget.sample;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.sampleDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showUpdateClassificationDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample Header
            _buildSampleHeader(),

            // Sample Photo Section
            if (currentSample.photo != null) _buildPhotoSection(),

            // Classification Section
            _buildClassificationSection(),

            // Size Information
            if (currentSample.height != null || currentSample.width != null)
              _buildSizeSection(),

            // Professional Information
            _buildProfessionalSection(),

            // Metadata Section
            _buildMetadataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleHeader() {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.l10n.sample} #${currentSample.id}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.wound != null)
                      Text(
                        widget.wound!.location,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      currentSample.hasBeenReviewed
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        currentSample.hasBeenReviewed
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            currentSample.hasBeenReviewed
                                ? Colors.green
                                : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentSample.hasBeenReviewed
                          ? context.l10n.reviewed
                          : context.l10n.pendingReview,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            currentSample.hasBeenReviewed
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sample date and time info
          Row(
            children: [
              Expanded(
                child: _buildMetadataItem(
                  icon: Icons.calendar_today,
                  label: context.l10n.sampleDate,
                  value: currentSample.formattedDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetadataItem(
                  icon: Icons.access_time,
                  label: context.l10n.timeSince,
                  value: currentSample.timeSinceCreation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.woundPhoto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      currentSample.photo != null
                          ? Image(
                            image: ImageUtils.getImageProvider(
                              currentSample.photoUrl,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                          )
                          : const Center(child: Icon(Icons.no_photography)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.wagnerClassification,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (!currentSample.hasBeenReviewed)
                    TextButton.icon(
                      onPressed: _showUpdateClassificationDialog,
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(context.l10n.review),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Classification (only show if available)
              if (currentSample.aiClassification != null)
                _buildClassificationCard(
                  title: context.l10n.aiClassification,
                  classification: currentSample.aiClassification!,
                  subtitle: context.l10n.automaticAnalysis,
                  icon: Icons.smart_toy,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.noAiClassification,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.photoRequiredForAnalysis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Professional Classification
              if (currentSample.professionalClassification != null)
                _buildClassificationCard(
                  title: context.l10n.professionalReview,
                  classification: currentSample.professionalClassification!,
                  subtitle: context.l10n.clinicalAssessment,
                  icon: Icons.verified_user,
                  isEffective: true,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pending_actions,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.awaitingProfessionalReview,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.clickReviewToAdd,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationCard({
    required String title,
    required WagnerClassification classification,
    required String subtitle,
    required IconData icon,
    bool isEffective = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEffective ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEffective ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: classification.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: classification.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  classification.localizedDescription,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: classification.color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (isEffective)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                context.l10n.active,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSizeSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.woundMeasurements,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSizeCard(
                      icon: Icons.straighten,
                      label: context.l10n.dimensions,
                      value:
                          currentSample.height != null &&
                                  currentSample.width != null
                              ? '${currentSample.height!.toStringAsFixed(1)} x ${currentSample.width!.toStringAsFixed(1)} cm'
                              : 'N/A',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSizeCard(
                      icon: Icons.crop_free,
                      label: context.l10n.area,
                      value:
                          '${currentSample.area != null ? currentSample.area!.toStringAsFixed(1) : 'N/A'} cm²',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.responsibleProfessional,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSample.professionalCoren,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${context.l10n.idLabel}: ${currentSample.professionalCoren}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.sampleInformation,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoRow(
                Icons.fingerprint,
                context.l10n.sampleId,
                currentSample.id.toString(),
              ),
              const SizedBox(height: 12),

              _buildInfoRow(
                Icons.medical_services,
                context.l10n.woundId,
                currentSample.woundId.toString(),
              ),
              const SizedBox(height: 12),

              _buildInfoRow(
                Icons.add_circle,
                context.l10n.created,
                currentSample.createdAt.formattedDateTimeWithTimezone,
              ),
              const SizedBox(height: 12),

              _buildInfoRow(
                Icons.update,
                context.l10n.lastUpdated,
                currentSample.updatedAt.formattedDateTimeWithTimezone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showUpdateClassificationDialog() {
    WagnerClassification? selectedClassification =
        currentSample.professionalClassification;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(context.l10n.updateClassification),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.aiClassificationColon} ${currentSample.aiClassification?.localizedDescription ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Text(
                  '${context.l10n.professionalAssessment}:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...WagnerClassification.values.map((classification) {
                  return RadioListTile<WagnerClassification>(
                    title: Text(
                      classification.localizedDescription,
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: classification,
                    groupValue: selectedClassification,
                    onChanged: (WagnerClassification? value) {
                      setState(() {
                        selectedClassification = value;
                      });
                    },
                    dense: true,
                  );
                }),
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
                      sampleController.isWorking.value
                          ? null
                          : () => _updateClassification(selectedClassification),
                  child:
                      sampleController.isWorking.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(context.l10n.update),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateClassification(
    WagnerClassification? classification,
  ) async {
    if (classification == null) return;

    try {
      await sampleController.updateSample(currentSample.id, {
        'professional_classification': classification.grade,
      });

      // Reload the sample to get updated data
      final updatedSample = await SampleService().getSample(currentSample.id);
      setState(() {
        currentSample = updatedSample;
      });
    } catch (e) {
      // Error handling is done in the controller
    } finally {
      // Always close the dialog, whether success or error
      Get.back();
    }
  }

  void _showDeleteConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(context.l10n.deleteSampleConfirm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.deleteSampleConfirm),
            const SizedBox(height: 8),
            Text(
              '${context.l10n.sampleNumber} #${currentSample.id}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
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
                  sampleController.isWorking.value ? null : _deleteSample,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child:
                  sampleController.isWorking.value
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

  Future<void> _deleteSample() async {
    // Extract localized strings before async gap
    final successTitle = context.l10n.success;
    final successMessage = context.l10n.sampleDeletedSuccessfully;
    final errorTitle = context.l10n.error;
    final errorMessage = context.l10n.failedToDeleteSample;

    try {
      await sampleController.deleteSample(currentSample.id);

      // Close confirmation dialog first
      Get.back();

      // Then navigate back to the previous screen
      Get.back();

      // Show success message
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
}
