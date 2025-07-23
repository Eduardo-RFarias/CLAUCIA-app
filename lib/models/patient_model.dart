import 'package:equatable/equatable.dart';
import '../services/localization_service.dart';
import '../utils/image_utils.dart';

/// Possible patient biological sex values returned by the API.
enum Sex { male, female }

extension SexParsing on Sex {
  static Sex fromString(String value) {
    switch (value.toUpperCase()) {
      case 'M':
        return Sex.male;
      case 'F':
        return Sex.female;
      default:
        throw ArgumentError('Unknown sex value: $value');
    }
  }

  String toShortString() => this == Sex.male ? 'M' : 'F';

  String get localizedValue => this == Sex.male ? l10n.male : l10n.female;
}

class Patient extends Equatable {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final Sex sex;
  final String? photo; // URL or base64 string
  final String institutionName;
  final String? medicalConditions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.sex,
    this.photo,
    required this.institutionName,
    this.medicalConditions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as int,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      sex: SexParsing.fromString(json['sex'] as String),
      photo: json['photo'] as String?,
      institutionName: json['institution_name'] as String,
      medicalConditions: json['medical_conditions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'sex': sex.toShortString(),
      'photo': photo,
      'institution_name': institutionName,
      'medical_conditions': medicalConditions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get age {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years;
  }

  String get ageString => l10n.yearsOld(age);

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'P';
    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final firstInitial = parts.first.substring(0, 1).toUpperCase();
    final lastInitial = parts.last.substring(0, 1).toUpperCase();
    return '$firstInitial$lastInitial';
  }

  /// Returns the full URL for the patient's photo
  String get photoUrl => ImageUtils.pathToUrl(photo);

  Patient copyWith({
    int? id,
    String? name,
    DateTime? dateOfBirth,
    Sex? sex,
    String? photo,
    String? institutionName,
    String? medicalConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      photo: photo ?? this.photo,
      institutionName: institutionName ?? this.institutionName,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    dateOfBirth,
    sex,
    photo,
    institutionName,
    medicalConditions,
    createdAt,
    updatedAt,
  ];
}
