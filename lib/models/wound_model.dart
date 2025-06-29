import 'package:flutter/material.dart';
import 'sample_model.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';

enum WoundOrigin {
  diabeticUlcers('Diabetic Ulcers'),
  nonDiabeticUlcers('Non-Diabetic Ulcers'),
  neuropathicUlcers('Neuropathic Ulcers'),
  venousUlcers('Venous Ulcers');

  const WoundOrigin(this.displayName);
  final String displayName;

  // Get localized display name
  String get localizedDisplayName {
    switch (this) {
      case WoundOrigin.diabeticUlcers:
        return l10n.diabeticUlcers;
      case WoundOrigin.nonDiabeticUlcers:
        return l10n.nonDiabeticUlcers;
      case WoundOrigin.neuropathicUlcers:
        return l10n.neuropathicUlcers;
      case WoundOrigin.venousUlcers:
        return l10n.venousUlcers;
    }
  }
}

class Wound {
  final int id;
  final int patientId;
  final String location;
  final WoundOrigin origin;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  final List<Sample> samples;

  Wound({
    required this.id,
    required this.patientId,
    required this.location,
    required this.origin,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.samples = const <Sample>[],
  });

  factory Wound.fromJson(Map<String, dynamic> json) {
    return Wound(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? 0,
      location: json['location'] ?? '',
      origin: WoundOrigin.values.firstWhere(
        (e) => e.name == json['origin'],
        orElse: () => WoundOrigin.diabeticUlcers,
      ),
      description: json['description'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      samples:
          json['samples'] != null
              ? (json['samples'] as List)
                  .map((sampleJson) => Sample.fromJson(sampleJson))
                  .toList()
              : <Sample>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'location': location,
      'origin': origin.name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'samples': samples.map((sample) => sample.toJson()).toList(),
    };
  }

  Wound copyWith({
    int? id,
    int? patientId,
    String? location,
    WoundOrigin? origin,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<Sample>? samples,
  }) {
    return Wound(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      location: location ?? this.location,
      origin: origin ?? this.origin,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      samples: samples ?? this.samples,
    );
  }

  // Get formatted days since creation
  String get daysSinceCreation {
    return createdAt.relativeDate;
  }

  // Get status color based on activity
  Color get statusColor {
    return isActive ? Colors.orange : Colors.green;
  }

  // Get status text
  String get statusText {
    return isActive ? l10n.statusActive : l10n.statusHealed;
  }
}
