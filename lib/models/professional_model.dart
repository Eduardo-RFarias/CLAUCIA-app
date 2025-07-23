import 'package:equatable/equatable.dart';
import '../utils/image_utils.dart';

class Professional extends Equatable {
  final String coren;
  final String name;
  final String? photo; // url or base64
  final DateTime createdAt;
  final DateTime updatedAt;

  /// JWT or session token received after login. Not part of the DTO but
  /// convenient to keep alongside the model on the client.
  final String? token;

  const Professional({
    required this.coren,
    required this.name,
    this.photo,
    required this.createdAt,
    required this.updatedAt,
    this.token,
  });

  factory Professional.fromJson(Map<String, dynamic> json, {String? token}) {
    return Professional(
      coren: json['coren'] as String,
      name: json['name'] as String,
      photo: json['photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
    'coren': coren,
    'name': name,
    'photo': photo,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    if (token != null) 'token': token,
  };

  /// Returns the full URL for the professional's photo
  String get photoUrl => ImageUtils.pathToUrl(photo);

  Professional copyWith({
    String? coren,
    String? name,
    String? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token,
  }) {
    return Professional(
      coren: coren ?? this.coren,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [coren, name, photo, createdAt, updatedAt, token];
}
