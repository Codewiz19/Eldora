// // lib/models/caretaker_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'user_model.dart';

// class CaretakerModel extends UserModel {
//   final List<DocumentReference> elderIds;
//   String? fcmToken; // Add this

//   CaretakerModel({
//     required super.id,
//     required super.name,
//     required super.email,
//     required this.elderIds,
//     this.fcmToken, // Add this
//   }) : super(userType: 'caretaker');

//   factory CaretakerModel.fromMap(Map<String, dynamic> map, String id) {
//     return CaretakerModel(
//       id: id,
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       elderIds: (map['elderIds'] as List?)
//               ?.map((ref) => ref as DocumentReference)
//               .toList() ??
//           [],
//     );
//   }

//   @override
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'email': email,
//       'userType': userType,
//       'elderIds': elderIds,
//     };
//   }
// }

// lib/models/caretaker_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class CaretakerModel extends UserModel {
  final List<DocumentReference> elderIds;
  String? fcmToken; // Add this

  CaretakerModel({
    required super.id,
    required super.name,
    required super.email,
    required this.elderIds,
    this.fcmToken, // Add this
  }) : super(userType: 'caretaker');

  factory CaretakerModel.fromMap(Map<String, dynamic> map, String id) {
    return CaretakerModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      elderIds: (map['elderIds'] as List?)
              ?.map((ref) => ref as DocumentReference)
              .toList() ??
          [],
      fcmToken: map['fcmToken'], // Added here
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userType': userType,
      'elderIds': elderIds,
      'fcmToken': fcmToken, // Added here
    };
  }
}
