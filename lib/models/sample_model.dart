import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../services/date_service.dart';
import '../services/localization_service.dart';

/// Mapping of Wagner ulcer classification used by both AI & professionals.
/// Backend returns an `int` (0–5). We keep the rich enum for UI while storing
/// the raw integer in JSON.
enum WagnerClassification {
  grade0(0, 'No open lesion'),
  grade1(1, 'Superficial lesion'),
  grade2(2, 'Deep ulcer'),
  grade3(3, 'Abscess / osteomyelitis'),
  grade4(4, 'Partial foot gangrene'),
  grade5(5, 'Whole foot gangrene');

  const WagnerClassification(this.grade, this.description);
  final int grade;
  final String description;

  String get displayName => '${l10n.grade} $grade: $localizedDescription';

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

  static WagnerClassification fromInt(int? grade) {
    return WagnerClassification.values.firstWhere(
      (e) => e.grade == grade,
      orElse: () => WagnerClassification.grade0,
    );
  }
}

class Sample extends Equatable {
  final int id;
  final int woundId;
  final String? photo; // url / base64 image
  final WagnerClassification? aiClassification;
  final WagnerClassification? professionalClassification;
  final double? height; // centimetres
  final double? width; // centimetres
  final DateTime date;
  final String professionalCoren;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sample({
    required this.id,
    required this.woundId,
    this.photo,
    this.aiClassification,
    this.professionalClassification,
    this.height,
    this.width,
    required this.date,
    required this.professionalCoren,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sample.fromJson(Map<String, dynamic> json) {
    return Sample(
      id: json['id'] as int,
      woundId: json['wound_id'] as int,
      photo: json['photo'] as String?,
      aiClassification:
          json['ai_classification'] != null
              ? WagnerClassification.fromInt(json['ai_classification'] as int)
              : null,
      professionalClassification:
          json['professional_classification'] != null
              ? WagnerClassification.fromInt(
                json['professional_classification'] as int,
              )
              : null,
      height: (json['height'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      date: DateTime.parse(json['date'] as String),
      professionalCoren: json['professional_coren']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wound_id': woundId,
      'photo': photo,
      'ai_classification': aiClassification?.grade,
      'professional_classification': professionalClassification?.grade,
      'height': height,
      'width': width,
      'date': date.toIso8601String(),
      'professional_coren': professionalCoren,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WagnerClassification get effectiveClassification =>
      professionalClassification ??
      aiClassification ??
      WagnerClassification.grade0;

  bool get hasBeenReviewed => professionalClassification != null;

  String get formattedDate => date.formattedDate;

  String get timeSinceCreation => date.relativeTime;

  double? get area =>
      (height != null && width != null) ? height! * width! : null;

  @override
  List<Object?> get props => [
    id,
    woundId,
    photo,
    aiClassification,
    professionalClassification,
    height,
    width,
    date,
    professionalCoren,
    createdAt,
    updatedAt,
  ];
}
