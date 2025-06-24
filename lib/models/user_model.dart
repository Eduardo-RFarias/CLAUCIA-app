class User {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'profilePicture': profilePicture,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? token,
    String? profilePicture,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
