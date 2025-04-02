import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String name;
  final String dosage;
  final String mealRelation; // "Before" or "After"
  final String mealType; // "Breakfast", "Lunch", or "Dinner"
  final DateTime scheduledTime;
  final String?
      photoUrl; // Optional URL to medication image in Firebase Storage

  MedicationModel({
    required this.name,
    required this.dosage,
    required this.mealRelation,
    required this.mealType,
    required this.scheduledTime,
    this.photoUrl,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      mealRelation: map['mealRelation'] ?? '',
      mealType: map['mealType'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'mealRelation': mealRelation,
      'mealType': mealType,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'photoUrl': photoUrl,
    };
  }
}
