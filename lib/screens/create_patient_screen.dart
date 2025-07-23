import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/app_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../dtos/create_patient_dto.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';
import '../utils/image_utils.dart';
import 'patient_detail_screen.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final PatientController patientController = Get.find();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  // Form state
  DateTime? _selectedDate;
  String? _selectedGender;
  File? _selectedImage;
  bool _isLoading = false;

  // Gender options will be initialized in build method

  @override
  void dispose() {
    _nameController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 30),
      ), // 30 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: context.l10n.selectDateOfBirth,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(context.l10n.takePhoto),
                onTap: () async {
                  Get.back();
                  await _getImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () async {
                  Get.back();
                  await _getImageFromSource(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(context.l10n.removePhoto),
                  onTap: () {
                    Get.back();
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _createPatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      Get.snackbar(
        context.l10n.error,
        context.l10n.pleaseSelectDateOfBirth,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    if (_selectedGender == null) {
      Get.snackbar(
        context.l10n.error,
        context.l10n.pleaseSelectBiologicSex,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Extract localized strings before async operations
    final errorTitle = context.l10n.error;
    final maleLabel = context.l10n.male;

    try {
      final appController = Get.find<AppController>();

      // Encode image to data URI if provided
      String? encodedPhoto;
      if (_selectedImage != null) {
        encodedPhoto = await ImageUtils.fileToDataUri(_selectedImage!);
      }

      final sexEnum = _selectedGender == maleLabel ? Sex.male : Sex.female;
      final dto = CreatePatientDto(
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDate!,
        sex: sexEnum.toShortString(),
        institutionName: appController.selectedInstitution.value,
        photo: encodedPhoto,
        medicalConditions:
            _medicalConditionsController.text.trim().isNotEmpty
                ? _medicalConditionsController.text.trim()
                : null,
      );

      final newPatient = await patientController.createPatient(dto);

      if (newPatient != null) {
        Get.off(() => PatientDetailScreen(patientId: newPatient.id));
      }
    } catch (e) {
      Get.snackbar(
        errorTitle,
        'Failed to create patient: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.createNewPatient),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      color: Colors.grey[50],
                    ),
                    child:
                        _selectedImage != null
                            ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey.shade100,
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.addPhotoOptional,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.fullNameRequired,
                  hintText: context.l10n.enterPatientFullName,
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.nameRequired;
                  }
                  if (value.trim().length < 2) {
                    return context.l10n.nameMinLength;
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Date of Birth field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.l10n.dateOfBirthRequired,
                    hintText: context.l10n.selectDateOfBirth,
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? _selectedDate!.formattedDate
                        : context.l10n.selectDateOfBirth,
                    style: TextStyle(
                      color:
                          _selectedDate != null
                              ? Colors.black
                              : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biologic Sex field
              Builder(
                builder: (context) {
                  final genderOptions = [
                    context.l10n.male,
                    context.l10n.female,
                  ];
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: context.l10n.biologicSexRequired,
                      hintText: context.l10n.selectBiologicSex,
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedGender,
                    items:
                        genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return context.l10n.biologicSexRequired2;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Medical Conditions field
              TextFormField(
                controller: _medicalConditionsController,
                decoration: InputDecoration(
                  labelText: context.l10n.medicalConditions,
                  hintText: context.l10n.enterMedicalConditions,
                  prefixIcon: Icon(Icons.medical_services),
                  border: OutlineInputBorder(),
                  helperText: context.l10n.medicalConditionsHelper,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  // Optional field, so no validation required
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            context.l10n.createPatient,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Required fields note
              Text(
                context.l10n.requiredFields,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
