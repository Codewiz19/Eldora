// // lib/models/elder_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'user_model.dart';

// class ElderModel extends UserModel {
//   final int age;
//   final String gender;
//   final List<DocumentReference> caretakerIds;

//   ElderModel({
//     required super.id,
//     required super.name,
//     required super.email,
//     required this.age,
//     required this.gender,
//     required this.caretakerIds,
//   }) : super(userType: 'elder');

//   factory ElderModel.fromMap(Map<String, dynamic> map, String id) {
//     return ElderModel(
//       id: id,
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       age: map['age'] ?? 0,
//       gender: map['gender'] ?? '',
//       caretakerIds: (map['caretakerIds'] as List?)
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
//       'age': age,
//       'gender': gender,
//       'caretakerIds': caretakerIds,
//     };
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'user_model.dart';
// import 'medication_model.dart';

// class ElderModel extends UserModel {
//   final int age;
//   final String gender;
//   final List<DocumentReference> caretakerIds;
//   final List<MedicationModel> medications;
//   String? fcmToken; // Add this

//   ElderModel({
//     required super.id,
//     required super.name,
//     required super.email,
//     required this.age,
//     required this.gender,
//     required this.caretakerIds,
//     this.medications = const [],
//     this.fcmToken, // Add this
//   }) : super(userType: 'elder');

//   factory ElderModel.fromMap(Map<String, dynamic> map, String id) {
//     List<MedicationModel> medicationsList = [];
//     if (map['medications'] != null) {
//       medicationsList = (map['medications'] as List)
//           .map((medication) => MedicationModel.fromMap(medication))
//           .toList();
//     }

//     return ElderModel(
//       id: id,
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       age: map['age'] ?? 0,
//       gender: map['gender'] ?? '',
//       caretakerIds: (map['caretakerIds'] as List?)
//               ?.map((ref) => ref as DocumentReference)
//               .toList() ??
//           [],
//       medications: medicationsList,
//     );
//   }

//   @override
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'email': email,
//       'userType': userType,
//       'age': age,
//       'gender': gender,
//       'caretakerIds': caretakerIds,
//       'medications':
//           medications.map((medication) => medication.toMap()).toList(),
//     };
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';
import 'medication_model.dart';

class ElderModel extends UserModel {
  final int age;
  final String gender;
  final List<DocumentReference> caretakerIds;
  final List<MedicationModel> medications;
  String? fcmToken; // Add this

  ElderModel({
    required super.id,
    required super.name,
    required super.email,
    required this.age,
    required this.gender,
    required this.caretakerIds,
    this.medications = const [],
    this.fcmToken, // Add this
  }) : super(userType: 'elder');

  factory ElderModel.fromMap(Map<String, dynamic> map, String id) {
    List<MedicationModel> medicationsList = [];
    if (map['medications'] != null) {
      medicationsList = (map['medications'] as List)
          .map((medication) => MedicationModel.fromMap(medication))
          .toList();
    }

    return ElderModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      caretakerIds: (map['caretakerIds'] as List?)
              ?.map((ref) => ref as DocumentReference)
              .toList() ??
          [],
      medications: medicationsList,
      fcmToken: map['fcmToken'], // Added here
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userType': userType,
      'age': age,
      'gender': gender,
      'caretakerIds': caretakerIds,
      'medications':
          medications.map((medication) => medication.toMap()).toList(),
      'fcmToken': fcmToken, // Added here
    };
  }
}
