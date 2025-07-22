import 'package:flutter/foundation.dart';

/// Data Transfer Object used when creating a new patient (matches CreatePatientDto in Swagger).
class CreatePatientDto {
  final String name;
  final DateTime dateOfBirth;

  /// "M" or "F"
  final String sex;
  final String institutionName;

  /// Base-64 string (or URL) – optional.
  final String? photo;
  final String? medicalConditions;

  const CreatePatientDto({
    required this.name,
    required this.dateOfBirth,
    required this.sex,
    required this.institutionName,
    this.photo,
    this.medicalConditions,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'sex': sex,
    'photo': photo,
    'institution_name': institutionName,
    if (medicalConditions != null) 'medical_conditions': medicalConditions,
  };

  @override
  String toString() => describeIdentity(this);
}
