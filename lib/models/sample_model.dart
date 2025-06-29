import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../services/date_service.dart';

enum WagnerClassification {
  grade0(0, 'No open Lesion'),
  grade1(1, 'Superficial Lesion'),
  grade2(2, 'Deep Ulcer'),
  grade3(3, 'Abscess/Osteomyelitis'),
  grade4(4, 'Partial Foot Gangrene'),
  grade5(5, 'Whole Foot Gangrene');

  const WagnerClassification(this.grade, this.description);
  final int grade;
  final String description;

  String get displayName => 'Grade $grade: $description';

  // Get localized description
  String get localizedDescription {
    switch (this) {
      case WagnerClassification.grade0:
        return l10n.wagnerGrade0;
      case WagnerClassification.grade1:
        return l10n.wagnerGrade1;
      case WagnerClassification.grade2:
        return l10n.wagnerGrade2;
      case WagnerClassification.grade3:
        return l10n.wagnerGrade3;
      case WagnerClassification.grade4:
        return l10n.wagnerGrade4;
      case WagnerClassification.grade5:
        return l10n.wagnerGrade5;
    }
  }

  String get localizedDisplayName =>
      '${l10n.grade} $grade: $localizedDescription';

  // Get color based on grade severity
  Color get color {
    switch (this) {
      case WagnerClassification.grade0:
        return Colors.green;
      case WagnerClassification.grade1:
        return Colors.lightGreen;
      case WagnerClassification.grade2:
        return Colors.yellow.shade700;
      case WagnerClassification.grade3:
        return Colors.orange;
      case WagnerClassification.grade4:
        return Colors.red.shade700;
      case WagnerClassification.grade5:
        return Colors.red.shade900;
    }
  }
}

class WoundSize {
  final double height; // in centimeters
  final double width; // in centimeters

  WoundSize({required this.height, required this.width});

  factory WoundSize.fromJson(Map<String, dynamic> json) {
    return WoundSize(
      height: (json['height'] ?? 0.0).toDouble(),
      width: (json['width'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'height': height, 'width': width};
  }

  String get displayText =>
      '${height.toStringAsFixed(1)} x ${width.toStringAsFixed(1)} ${l10n.cmUnit}';
  double get area => height * width;
}

class Sample {
  final int id;
  final int woundId;
  final String? woundPhoto; // Path to the wound photo
  final WagnerClassification?
  mlClassification; // ML model classification (null if no photo provided)
  final WagnerClassification?
  professionalClassification; // User can set this later
  final WoundSize? size; // Optional size measurements
  final DateTime date; // Sample date
  final int responsibleProfessionalId; // Current user ID
  final String responsibleProfessionalName; // Current user name
  final DateTime createdAt;
  final DateTime updatedAt;

  Sample({
    required this.id,
    required this.woundId,
    this.woundPhoto,
    this.mlClassification, // Now nullable - set only when photo is provided
    this.professionalClassification,
    this.size,
    required this.date,
    required this.responsibleProfessionalId,
    required this.responsibleProfessionalName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sample.fromJson(Map<String, dynamic> json) {
    return Sample(
      id: json['id'] ?? 0,
      woundId: json['woundId'] ?? 0,
      woundPhoto: json['woundPhoto'],
      mlClassification:
          json['mlClassification'] != null
              ? WagnerClassification.values.firstWhere(
                (e) => e.grade == json['mlClassification'],
              )
              : null,
      professionalClassification:
          json['professionalClassification'] != null
              ? WagnerClassification.values.firstWhere(
                (e) => e.grade == json['professionalClassification'],
                orElse: () => WagnerClassification.grade0,
              )
              : null,
      size: json['size'] != null ? WoundSize.fromJson(json['size']) : null,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      responsibleProfessionalId: json['responsibleProfessionalId'] ?? 0,
      responsibleProfessionalName: json['responsibleProfessionalName'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'woundId': woundId,
      'woundPhoto': woundPhoto,
      'mlClassification': mlClassification?.grade,
      'professionalClassification': professionalClassification?.grade,
      'size': size?.toJson(),
      'date': date.toIso8601String(),
      'responsibleProfessionalId': responsibleProfessionalId,
      'responsibleProfessionalName': responsibleProfessionalName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Sample copyWith({
    int? id,
    int? woundId,
    String? woundPhoto,
    WagnerClassification? mlClassification,
    WagnerClassification? professionalClassification,
    WoundSize? size,
    DateTime? date,
    int? responsibleProfessionalId,
    String? responsibleProfessionalName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sample(
      id: id ?? this.id,
      woundId: woundId ?? this.woundId,
      woundPhoto: woundPhoto ?? this.woundPhoto,
      mlClassification: mlClassification ?? this.mlClassification,
      professionalClassification:
          professionalClassification ?? this.professionalClassification,
      size: size ?? this.size,
      date: date ?? this.date,
      responsibleProfessionalId:
          responsibleProfessionalId ?? this.responsibleProfessionalId,
      responsibleProfessionalName:
          responsibleProfessionalName ?? this.responsibleProfessionalName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get the effective classification (professional override, ML, or fallback)
  WagnerClassification get effectiveClassification {
    // Priority: Professional classification > ML classification > Grade 0 fallback
    return professionalClassification ??
        mlClassification ??
        WagnerClassification.grade0;
  }

  // Check if professional has overridden the ML classification
  bool get hasBeenReviewed => professionalClassification != null;

  // Get formatted date
  String get formattedDate {
    return date.formattedDate;
  }

  // Get time since sample
  String get timeSinceCreation {
    return date.relativeTime;
  }
}
