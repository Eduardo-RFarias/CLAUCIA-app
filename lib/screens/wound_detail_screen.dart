import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/wound_model.dart';
import '../models/sample_model.dart';
import '../controllers/wound_controller.dart';
import '../controllers/sample_controller.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';
import '../utils/image_utils.dart';
import 'add_sample_screen.dart';
import 'sample_detail_screen.dart';
import '../services/wound_service.dart';

class WoundDetailScreen extends StatefulWidget {
  final int woundId;

  const WoundDetailScreen({super.key, required this.woundId});

  @override
  State<WoundDetailScreen> createState() => _WoundDetailScreenState();
}

class _WoundDetailScreenState extends State<WoundDetailScreen> {
  final SampleController sampleController = Get.find<SampleController>();
  final WoundController woundController = Get.find<WoundController>();
  final WoundService _woundService = WoundService();

  Wound? _wound;
  bool _loadingWound = true;

  @override
  void initState() {
    super.initState();
    _loadWound();
  }

  Future<void> _loadWound() async {
    try {
      final w = await _woundService.getWound(widget.woundId);
      setState(() {
        _wound = w;
        _loadingWound = false;
      });
      await sampleController.loadSamplesByWound(w.id);
    } catch (_) {
      setState(() => _loadingWound = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingWound) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_wound == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.error)),
        body: Center(child: Text(context.l10n.error)),
      );
    }

    final wound = _wound!;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.woundDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(wound);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Wound Information Header
          _buildWoundHeader(wound),

          // Samples Section
          Expanded(child: _buildSamplesSection(wound)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => AddSampleScreen(wound: wound));
          // Refresh samples after returning
          sampleController.loadSamplesByWound(wound.id);
        },
        icon: const Icon(Icons.add_a_photo),
        label: Text(context.l10n.addSample),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildWoundHeader(Wound wound) {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wound location and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wound.location,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wound.origin.localizedDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Simple status text (color logic removed)
              Text(
                wound.statusText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description if available
          if (wound.description != null && wound.description!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                wound.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Wound metadata
          Row(
            children: [
              Expanded(
                child: _buildMetadataItem(
                  icon: Icons.calendar_today,
                  label: context.l10n.created,
                  value: wound.createdAt.formattedDateTimeWithTimezone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetadataItem(
                  icon: Icons.update,
                  label: context.l10n.lastUpdated,
                  value: wound.daysSinceCreation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade600),
        const SizedBox(width: 6),
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSamplesSection(Wound wound) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Samples header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.sampleHistory,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final samplesCount = sampleController.samples.length;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$samplesCount ${context.l10n.sample}${samplesCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Samples list
          Expanded(
            child: Obx(() {
              if (sampleController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (sampleController.samples.isEmpty) {
                return _buildEmptyState(wound);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sampleController.samples.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sample = sampleController.samples[index];
                  return _buildSampleCard(sample, index, wound);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Wound wound) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_camera,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noSamplesYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.startDocumentingWound,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Get.to(() => AddSampleScreen(wound: wound));
              // Always refresh samples when returning from add sample screen
              sampleController.loadSamplesByWound(wound.id);
            },
            icon: const Icon(Icons.add_a_photo, size: 18),
            label: Text(context.l10n.addFirstSample),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleCard(Sample sample, int index, Wound wound) {
    final isLatest = index == 0;

    return InkWell(
      onTap: () {
        Get.to(() => SampleDetailScreen(sample: sample, wound: wound));
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: isLatest ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isLatest
                  ? BorderSide(color: Colors.blue.shade200, width: 1)
                  : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient:
                isLatest
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade50, Colors.white],
                    )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sample header
                Row(
                  children: [
                    if (isLatest) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.l10n.latest,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      Icons.analytics,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${context.l10n.sample} #${sample.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      sample.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Photo section
                if (sample.photo != null) ...[
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: ImageUtils.getImageProvider(sample.photoUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 24,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.noPhoto,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Wagner classification
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color:
                            (sample.aiClassification != null ||
                                    sample.professionalClassification != null)
                                ? sample.effectiveClassification.color
                                : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.wagnerClassification,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            (sample.aiClassification != null ||
                                    sample.professionalClassification != null)
                                ? sample
                                    .effectiveClassification
                                    .localizedDescription
                                : context.l10n.pendingAssessment,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  (sample.aiClassification != null ||
                                          sample.professionalClassification !=
                                              null)
                                      ? sample.effectiveClassification.color
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sample.hasBeenReviewed) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 12,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.reviewed,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pending,
                              size: 12,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.pendingReview,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Size information if available
                if (sample.height != null && sample.width != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${context.l10n.size}: ${sample.height!.toStringAsFixed(1)} x ${sample.width!.toStringAsFixed(1)} cm',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${context.l10n.area}: ${sample.area != null ? sample.area!.toStringAsFixed(1) : 'N/A'} ${context.l10n.cm2Unit}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Responsible professional and timestamp
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      sample.professionalCoren,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      sample.timeSinceCreation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Wound wound) {
    Get.dialog(
      AlertDialog(
        title: Text(context.l10n.deleteWound),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.deleteWoundConfirm),
            const SizedBox(height: 8),
            Text(
              wound.location,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will also delete all ${sampleController.samples.length} associated samples.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
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
                  woundController.isLoading.value
                      ? null
                      : () => _deleteWound(wound),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child:
                  woundController.isLoading.value
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

  Future<void> _deleteWound(Wound wound) async {
    // Extract localized strings before async gap
    final successTitle = context.l10n.success;
    final successMessage = context.l10n.woundDeletedSuccessfully;
    final errorTitle = context.l10n.error;
    final errorMessage = context.l10n.failedToDeleteWound;

    try {
      await woundController.deleteWound(wound.id);

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
}
