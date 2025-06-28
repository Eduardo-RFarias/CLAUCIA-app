import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/wound_model.dart';
import '../models/sample_model.dart';
import '../controllers/sample_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/image_processor.dart';

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
        title: const Text('Add Sample'),
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
                    color: widget.wound.statusColor,
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
                    color: widget.wound.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.wound.statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.wound.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.wound.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.wound.origin.displayName,
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
                  'Created ${widget.wound.daysSinceCreation}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.photo_library,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.wound.samples.length} sample${widget.wound.samples.length != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
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
          'New Sample',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Capture a new sample to track wound progress',
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
                  'Wound Photo',
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
                    'Photo processed (224x224px)',
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
                    label: const Text('Take Photo'),
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
                    label: const Text('Gallery'),
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
                  label: const Text('Retake Photo'),
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
                  'Size Measurements',
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
                'Enter wound dimensions in centimeters',
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
                        labelText: 'Height (cm)',
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
                        labelText: 'Width (cm)',
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
                'Toggle to add optional size measurements',
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
                ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Processing Sample...'),
                  ],
                )
                : const Text(
                  'Add Sample',
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
    // Validate that at least photo or size is provided
    if (_croppedImagePath == null && !_hasOptionalSize) {
      Get.snackbar(
        'Validation Error',
        'Please provide either a photo or size measurements',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate size measurements if provided
    if (_hasOptionalSize) {
      if (_heightController.text.isEmpty || _widthController.text.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please fill in both height and width measurements',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final height = double.tryParse(_heightController.text);
      final width = double.tryParse(_widthController.text);

      if (height == null || width == null || height <= 0 || width <= 0) {
        Get.snackbar(
          'Validation Error',
          'Please enter valid positive numbers for measurements',
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
      final currentUser = authController.currentUser.value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create wound size if measurements are provided
      WoundSize? size;
      if (_hasOptionalSize &&
          _heightController.text.isNotEmpty &&
          _widthController.text.isNotEmpty) {
        final height = double.parse(_heightController.text);
        final width = double.parse(_widthController.text);
        size = WoundSize(height: height, width: width);
      }

      // Create the sample without snackbar to avoid navigation conflicts
      await sampleController.createSample(
        woundId: widget.wound.id,
        woundPhoto: _croppedImagePath,
        size: size,
      );

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
        'Error',
        'Failed to create sample: ${e.toString()}',
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
