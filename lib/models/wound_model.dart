import 'package:equatable/equatable.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';

enum WoundOrigin {
  diabeticUlcers('Diabetic Ulcers'),
  nonDiabeticUlcers('Non-Diabetic Ulcers'),
  neuropathicUlcers('Neuropathic Ulcers'),
  venousUlcers('Venous Ulcers');

  const WoundOrigin(this.displayName);
  final String displayName;

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

  static WoundOrigin? fromString(String? raw) {
    if (raw == null) return null;
    switch (raw.toLowerCase()) {
      case 'diabetic ulcers':
        return WoundOrigin.diabeticUlcers;
      case 'non-diabetic ulcers':
        return WoundOrigin.nonDiabeticUlcers;
      case 'neuropathic ulcers':
        return WoundOrigin.neuropathicUlcers;
      case 'venous ulcers':
        return WoundOrigin.venousUlcers;
      default:
        return null;
    }
  }
}

class Wound extends Equatable {
  final int id;
  final int patientId;
  final String location;
  final WoundOrigin origin;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wound({
    required this.id,
    required this.patientId,
    required this.location,
    required this.origin,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wound.fromJson(Map<String, dynamic> json) {
    return Wound(
      id: json['id'] as int,
      patientId: json['patient_id'] as int,
      location: json['location'] as String,
      origin:
          WoundOrigin.fromString(json['origin'] as String) ??
          WoundOrigin.diabeticUlcers,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'location': location,
      'origin': origin.displayName,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
  }) {
    return Wound(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      location: location ?? this.location,
      origin: origin ?? this.origin,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get daysSinceCreation => createdAt.relativeDate;
  String get statusText => l10n.statusActive;

  @override
  List<Object?> get props => [
    id,
    patientId,
    location,
    origin,
    description,
    createdAt,
    updatedAt,
  ];
}
