class UserApiModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? birthday;
  final String? photoURL;
  final String roleId;
  final DateTime createdAt;

  UserApiModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthday,
    this.photoURL,
    required this.roleId,
    required this.createdAt,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      birthday: json['birthday'],
      photoURL: json['photoURL'],
      roleId: json['roleId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthday': birthday,
      'photoURL': photoURL,
      'roleId': roleId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

