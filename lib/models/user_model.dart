// lib/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String userType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userType: map['userType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userType': userType,
    };
  }
}
