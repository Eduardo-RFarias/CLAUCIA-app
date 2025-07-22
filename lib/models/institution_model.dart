import 'package:equatable/equatable.dart';

class Institution extends Equatable {
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Institution({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [name, createdAt, updatedAt];
}
