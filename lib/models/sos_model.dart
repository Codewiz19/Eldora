import 'package:cloud_firestore/cloud_firestore.dart';

class SOSModel {
  String? reason;
  final String id;
  final String elderId;
  final String elderName;
  final DateTime timestamp;
  final GeoPoint location;
  final String? mediaUrl;
  final bool resolved;

  SOSModel({
    required this.id,
    required this.elderId,
    required this.elderName,
    required this.timestamp,
    required this.location,
    this.mediaUrl,
    this.resolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'elderId': elderId,
      'elderName': elderName,
      'timestamp': timestamp,
      'location': location,
      'mediaUrl': mediaUrl,
      'resolved': resolved,
    };
  }

  factory SOSModel.fromMap(Map<String, dynamic> map) {
    return SOSModel(
      id: map['id'],
      elderId: map['elderId'],
      elderName: map['elderName'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      location: map['location'],
      mediaUrl: map['mediaUrl'],
      resolved: map['resolved'] ?? false,
    );
  }
}
