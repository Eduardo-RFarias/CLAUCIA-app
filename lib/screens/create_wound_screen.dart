import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import '../models/patient_model.dart';
import '../models/wound_model.dart';
import '../models/sample_model.dart';
import '../controllers/wound_controller.dart';
import '../controllers/sample_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/image_processor.dart';
import '../services/localization_service.dart';
import 'wound_detail_screen.dart';

class CreateWoundScreen extends StatefulWidget {
  final Patient patient;

  const CreateWoundScreen({super.key, required this.patient});

  @override
  State<CreateWoundScreen> createState() => _CreateWoundScreenState();
}

class _CreateWoundScreenState extends State<CreateWoundScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final WoundController woundController = Get.find<WoundController>();
  final SampleController sampleController = Get.find<SampleController>();

  // Form controllers
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();

  // Form state
  WoundOrigin? _selectedOrigin;
  String? _croppedImagePath;
  bool _isCreating = false;
  bool _hasOptionalSize = false;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.createNewWound),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient info header
              _buildPatientHeader(),
              const SizedBox(height: 24),

              // Wound Information Section
              _buildWoundInformationSection(),
              const SizedBox(height: 32),

              // Sample Information Section
              _buildSampleSection(),
              const SizedBox(height: 32),

              // Create button
              _buildCreateButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
                  widget.patient.profilePicture != null &&
                          widget.patient.profilePicture!.isNotEmpty
                      ? (widget.patient.profilePicture!.startsWith('http')
                              ? CachedNetworkImageProvider(
                                widget.patient.profilePicture!,
                              )
                              : FileImage(File(widget.patient.profilePicture!)))
                          as ImageProvider
                      : null,
              child:
                  widget.patient.profilePicture == null ||
                          widget.patient.profilePicture!.isEmpty
                      ? Text(
                        widget.patient.initials,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.patient.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${widget.patient.ageString} • ${widget.patient.localizedGender}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWoundInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.woundInformation,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Location field
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: context.l10n.woundLocationRequired,
            hintText: context.l10n.woundLocationHint,
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.pleaseEnterWoundLocation;
            }
            if (value.trim().length < 3) {
              return context.l10n.locationMinLength;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Origin dropdown
        DropdownButtonFormField<WoundOrigin>(
          value: _selectedOrigin,
          decoration: InputDecoration(
            labelText: context.l10n.woundOriginRequired,
            prefixIcon: const Icon(Icons.medical_services),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items:
              WoundOrigin.values.map((origin) {
                return DropdownMenuItem(
                  value: origin,
                  child: Text(origin.localizedDisplayName),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedOrigin = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return context.l10n.pleaseSelectWoundOrigin;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Description field
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.descriptionOptional,
            hintText: context.l10n.additionalWoundDetails,
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSampleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.initialSample,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.captureFirstSample,
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.heightCm,
                        hintText: '0.0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator:
                          _hasOptionalSize
                              ? (value) {
                                if (value != null && value.isNotEmpty) {
                                  final height = double.tryParse(value);
                                  if (height == null || height <= 0) {
                                    return context.l10n.enterValidHeight;
                                  }
                                }
                                return null;
                              }
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.widthCm,
                        hintText: '0.0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator:
                          _hasOptionalSize
                              ? (value) {
                                if (value != null && value.isNotEmpty) {
                                  final width = double.tryParse(value);
                                  if (width == null || width <= 0) {
                                    return context.l10n.enterValidWidth;
                                  }
                                }
                                return null;
                              }
                              : null,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                context.l10n.sizeMeasurementsOptional,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
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
        onPressed: _isCreating ? null : _createWound,
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
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(context.l10n.creatingWound),
                  ],
                )
                : Text(
                  context.l10n.createWound,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final processedImagePath = await ImageProcessor.pickAndProcessImage(
      source: source,
      filePrefix: 'wound',
    );

    if (processedImagePath != null) {
      setState(() {
        _croppedImagePath = processedImagePath;
      });
    }
  }

  Future<void> _createWound() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // Extract localized strings before async operations
    final errorTitle = context.l10n.error;

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

      // Create the wound first
      final newWound = Wound(
        id: 0, // Will be assigned by service
        patientId: widget.patient.id,
        location: _locationController.text.trim(),
        origin: _selectedOrigin!,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        samples: [], // Will add sample after wound is created
      );

      // Create wound through controller
      final createdWound = await woundController.createWound(newWound);

      if (createdWound == null) {
        throw Exception('Failed to create wound');
      }

      // Create the initial sample (always create one to document the wound's initial state)
      await sampleController.createSample(
        woundId: createdWound.id,
        woundPhoto: _croppedImagePath,
        size: size,
      );

      // Navigate to wound detail screen
      Get.off(() => WoundDetailScreen(wound: createdWound));

      // Refresh the wounds list
      woundController.loadWoundsByPatientId(widget.patient.id);
    } catch (e) {
      Get.snackbar(
        errorTitle,
        'Failed to create wound: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
}
