import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/auth_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/app_controller.dart';
import '../models/patient_model.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';
import 'create_patient_screen.dart';
import 'patient_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final PatientController patientController = Get.put(PatientController());
    final AppController appController = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            '${context.l10n.patients} - ${appController.displayInstitutionName}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => patientController.fetchPatients(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with Create Patient Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final user = authController.currentUser.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${context.l10n.welcomeBack2}${user?.name != null ? ', ${context.l10n.drPrefix} ${user!.name.split(' ').last}' : ''}!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => Text(
                                '${patientController.patientsCount} ${context.l10n.patientsRegistered}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          () => Get.to(() => const CreatePatientScreen()),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: Text(context.l10n.newPatient),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Patients List
          Expanded(
            child: Obx(() {
              if (patientController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (patientController.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.errorLoadingPatients,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        patientController.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => patientController.fetchPatients(),
                        child: Text(context.l10n.tryAgain),
                      ),
                    ],
                  ),
                );
              }

              if (patientController.patients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.noPatientsFound,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.addFirstPatientMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed:
                            () => Get.to(() => const CreatePatientScreen()),
                        icon: const Icon(Icons.person_add),
                        label: Text(context.l10n.addFirstPatient),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => patientController.fetchPatients(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: patientController.patients.length,
                  itemBuilder: (context, index) {
                    final patient = patientController.patients[index];
                    return _buildPatientCard(context, patient);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => Get.to(() => PatientDetailScreen(patientId: patient.id)),
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.shade100,
          backgroundImage:
              patient.photo != null && patient.photo!.isNotEmpty
                  ? (patient.photo!.startsWith('http')
                      ? CachedNetworkImageProvider(patient.photo!)
                      : _localImageProvider(patient.photo!))
                  : null,
          child:
              patient.photo == null || patient.photo!.isEmpty
                  ? Text(
                    patient.initials,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  )
                  : null,
        ),
        title: Text(
          patient.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${patient.ageString} • ${patient.sex.localizedValue}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            if (patient.medicalConditions != null &&
                patient.medicalConditions!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  context.l10n.hasMedicalConditions,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          patient.updatedAt.relativeDate,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  /// Converts a Base-64 string (raw or data URI) to MemoryImage, otherwise
  /// returns null so Flutter shows fallback avatar.
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
}
