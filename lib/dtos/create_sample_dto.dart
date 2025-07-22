import 'package:flutter/foundation.dart';

/// Data Transfer Object used when creating a new sample (matches CreateSampleDto in Swagger).
class CreateSampleDto {
  final String? photo; // Base64 or URL
  final int? aiClassification; // 0-5 Wagner grade
  final int? professionalClassification; // 0-5 Wagner grade
  final double? height;
  final double? width;
  final DateTime date;
  final int woundId;
  final String professionalCoren;

  const CreateSampleDto({
    required this.date,
    required this.woundId,
    required this.professionalCoren,
    this.photo,
    this.aiClassification,
    this.professionalClassification,
    this.height,
    this.width,
  });

  Map<String, dynamic> toJson() => {
    'photo': photo,
    'ai_classification': aiClassification,
    'professional_classification': professionalClassification,
    'height': height,
    'width': width,
    'date': date.toIso8601String(),
    'wound_id': woundId,
    'professional_coren': professionalCoren,
  }..removeWhere((key, value) => value == null);

  @override
  String toString() => describeIdentity(this);
}
