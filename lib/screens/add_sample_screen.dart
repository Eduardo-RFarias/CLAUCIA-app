import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../models/wound_model.dart';
import '../dtos/create_sample_dto.dart';
import '../controllers/sample_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/image_processor.dart';
import '../services/localization_service.dart';

class AddSampleScreen extends StatefulWidget {
  final Wound wound;

  const AddSampleScreen({super.key, required this.wound});

  @override
  State<AddSampleScreen> createState() => _AddSampleScreenState();
}

class _AddSampleScreenState extends State<AddSampleScreen> {
  final SampleController sampleController = Get.find<SampleController>();

  // Form controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();

  // Form state
  String? _croppedImagePath;
  bool _isCreating = false;
  bool _hasOptionalSize = false;

  @override
  void dispose() {
    _heightController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.addSample),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wound info header
            _buildWoundHeader(),
            const SizedBox(height: 24),

            // Sample Information Section
            _buildSampleSection(),
            const SizedBox(height: 32),

            // Create button
            _buildCreateButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWoundHeader() {
    const Color uiColor = Colors.blue;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: uiColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.wound.location,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
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
                    widget.wound.statusText,
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
            Text(
              widget.wound.origin.localizedDisplayName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.wound.description != null &&
                widget.wound.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.wound.description!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${context.l10n.created} ${widget.wound.daysSinceCreation}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.photo_library,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Obx(() {
                  final sampleController = Get.find<SampleController>();
                  final count =
                      sampleController.samples
                          .where((s) => s.woundId == widget.wound.id)
                          .length;
                  return Text(
                    '$count ${count == 1 ? context.l10n.sample : context.l10n.samples}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.newSample,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.captureNewSample,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Photo capture section
        _buildPhotoSection(),
        const SizedBox(height: 16),

        // Size measurements section
        _buildSizeSection(),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_camera, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.woundPhoto,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_croppedImagePath != null) ...[
              // Photo preview
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_croppedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.photoProcessed,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Photo capture buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(context.l10n.takePhoto),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(context.l10n.gallery),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            if (_croppedImagePath != null) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(context.l10n.retakePhoto),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.straighten, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.sizeMeasurements,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _hasOptionalSize,
                  onChanged: (value) {
                    setState(() {
                      _hasOptionalSize = value;
                      if (!value) {
                        _heightController.clear();
                        _widthController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_hasOptionalSize) ...[
              Text(
                context.l10n.enterWoundDimensions,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.heightCm,
                        hintText: '0.0',
                        prefixIcon: const Icon(Icons.height),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.widthCm,
                        hintText: '0.0',
                        prefixIcon: const Icon(Icons.width_wide),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                context.l10n.toggleSizeMeasurements,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createSample,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isCreating
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(context.l10n.processingSample),
                  ],
                )
                : Text(
                  context.l10n.addSample,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final processedImagePath = await ImageProcessor.pickAndProcessImage(
      source: source,
      filePrefix: 'sample',
    );

    if (processedImagePath != null) {
      setState(() {
        _croppedImagePath = processedImagePath;
      });
    }
  }

  Future<void> _createSample() async {
    // Capture localized strings before async operations
    final l10n = context.l10n;

    // Validate that at least photo or size is provided
    if (_croppedImagePath == null && !_hasOptionalSize) {
      Get.snackbar(
        l10n.validationError,
        l10n.providePhotoOrSize,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate size measurements if provided
    if (_hasOptionalSize) {
      if (_heightController.text.isEmpty || _widthController.text.isEmpty) {
        Get.snackbar(
          l10n.validationError,
          l10n.fillBothMeasurements,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final height = double.tryParse(_heightController.text);
      final width = double.tryParse(_widthController.text);

      if (height == null || width == null || height <= 0 || width <= 0) {
        Get.snackbar(
          l10n.validationError,
          l10n.enterValidNumbers,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final authController = Get.find<AuthController>();
      final professional = authController.currentUser.value;
      if (professional == null) {
        throw Exception('User not authenticated');
      }

      double? height;
      double? width;
      if (_hasOptionalSize &&
          _heightController.text.isNotEmpty &&
          _widthController.text.isNotEmpty) {
        height = double.parse(_heightController.text);
        width = double.parse(_widthController.text);
      }

      // Encode photo if available
      String? encodedPhoto;
      if (_croppedImagePath != null) {
        final bytes = await File(_croppedImagePath!).readAsBytes();
        encodedPhoto = base64Encode(bytes);
      }

      final sampleDto = CreateSampleDto(
        photo: encodedPhoto,
        height: height,
        width: width,
        date: DateTime.now(),
        woundId: widget.wound.id,
        professionalCoren: professional.coren,
      );

      await sampleController.createSample(sampleDto);

      // Reset loading state and navigate immediately (no snackbar)
      if (mounted) {
        setState(() {
          _isCreating = false;
        });

        // Direct GetX navigation without any snackbar interference
        Get.back();
      }
      return; // Exit early to avoid further code execution
    } catch (e) {
      Get.snackbar(
        l10n.error,
        '${l10n.failedToCreateSample}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
