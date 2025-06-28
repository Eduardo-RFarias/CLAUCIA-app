class Patient {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String gender;
  final String? medicalConditions;

  Patient({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
    required this.gender,
    this.medicalConditions,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      dateOfBirth:
          DateTime.tryParse(json['dateOfBirth'] ?? '') ?? DateTime.now(),
      profilePicture: json['profilePicture'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      gender: json['gender'] ?? '',
      medicalConditions: json['medicalConditions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'gender': gender,
      'medicalConditions': medicalConditions,
    };
  }

  Patient copyWith({
    int? id,
    String? name,
    DateTime? dateOfBirth,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? gender,
    String? medicalConditions,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }

  // Calculate age from date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Get formatted age string
  String get ageString => '$age years old';

  // Get initials for avatar
  String get initials {
    if (name.isEmpty) return 'P';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
