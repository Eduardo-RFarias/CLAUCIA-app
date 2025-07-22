import 'package:flutter/foundation.dart';

/// Data Transfer Object used when creating a new wound (matches CreateWoundDto in Swagger).
class CreateWoundDto {
  final String location;
  final String origin;
  final String? description;
  final int patientId;

  const CreateWoundDto({
    required this.location,
    required this.origin,
    required this.patientId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'location': location,
    'origin': origin,
    'description': description,
    'patient_id': patientId,
  }..removeWhere((key, value) => value == null);

  @override
  String toString() => describeIdentity(this);
}
