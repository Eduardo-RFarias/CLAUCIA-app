import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:convert';

import '../models/patient_model.dart';
import '../models/wound_model.dart';
import '../dtos/create_wound_dto.dart';
import '../dtos/create_sample_dto.dart';
import '../controllers/wound_controller.dart';
import '../controllers/sample_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/image_processor.dart';
import '../utils/image_utils.dart';
import '../services/localization_service.dart';
import '../services/patient_service.dart';
import 'wound_detail_screen.dart';

class CreateWoundScreen extends StatefulWidget {
  final int patientId;

  const CreateWoundScreen({super.key, required this.patientId});

  @override
  State<CreateWoundScreen> createState() => _CreateWoundScreenState();
}

class _CreateWoundScreenState extends State<CreateWoundScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final WoundController woundController = Get.put(WoundController());
  final SampleController sampleController = Get.put(SampleController());

  final PatientService _patientService = PatientService();

  Patient? _patient;
  bool _isLoadingPatient = true;
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
    final patient = _patient!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildPatientAvatar(patient, 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${patient.ageString} • ${patient.sex.localizedValue}',
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

  /// Decode base-64 or data URI to MemoryImage, else try local file.
  ImageProvider? _localImageProvider(String src) {
    final base64Part =
        src.startsWith('data:image/') ? src.split(',').last : src;
    try {
      final bytes = base64Decode(base64Part);
      return MemoryImage(bytes);
    } catch (_) {
      // Fallback to file path if decoding fails
      final file = File(src);
      return file.existsSync() ? FileImage(file) : null;
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
            fontSize: radius * 0.7, // Scale font size with radius
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
      final professional = authController.currentUser.value;
      if (professional == null) {
        throw Exception('User not authenticated');
      }

      // Size measurements (optional)
      double? height;
      double? width;
      if (_hasOptionalSize &&
          _heightController.text.isNotEmpty &&
          _widthController.text.isNotEmpty) {
        height = double.parse(_heightController.text);
        width = double.parse(_widthController.text);
      }

      // Build DTO and create wound via controller
      final woundDto = CreateWoundDto(
        location: _locationController.text.trim(),
        origin: _selectedOrigin!.displayName,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        patientId: _patient!.id,
      );

      final createdWound = await woundController.createWound(woundDto);

      if (createdWound == null) {
        throw Exception('Failed to create wound');
      }

      // Create the initial sample (always create one to document the wound's initial state)
      String? encodedPhoto;
      if (_croppedImagePath != null) {
        final imageFile = File(_croppedImagePath!);
        encodedPhoto = await ImageUtils.fileToDataUri(imageFile);
      }

      // professional already retrieved earlier

      final sampleDto = CreateSampleDto(
        photo: encodedPhoto,
        height: height,
        width: width,
        date: DateTime.now(),
        woundId: createdWound.id,
        professionalCoren: professional.coren,
      );

      await sampleController.createSample(sampleDto);

      // Navigate to wound detail screen
      Get.off(() => WoundDetailScreen(woundId: createdWound.id));

      // Refresh the wounds list
      woundController.loadWoundsByPatient(_patient!.id);
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
