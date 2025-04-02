import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import '../models/sos_model.dart';
import '../models/elder_model.dart';

class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // You'll need to set up a Cloud Function or a server for sending notifications
  // This is the URL of your Cloud Function that sends FCM notifications
  final String fcmSendUrl =
      'https://your-project-id.cloudfunctions.net/sendSOSNotification';

  // Singleton pattern
  static final SOSService _instance = SOSService._internal();
  factory SOSService() => _instance;
  SOSService._internal();

  // Method to create a new SOS alert
  Future<String> createSOSAlert({String? mediaUrl}) async {
    try {
      // Get current user (elder)
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get elder document
      DocumentSnapshot elderDoc =
          await _firestore.collection('elders').doc(currentUser.uid).get();

      if (!elderDoc.exists) {
        throw Exception('Elder profile not found');
      }

      Map<String, dynamic> elderData = elderDoc.data() as Map<String, dynamic>;

      // Get current location
      LocationData? locationData = await _getCurrentLocation();
      GeoPoint location = GeoPoint(
        locationData?.latitude ?? 0.0,
        locationData?.longitude ?? 0.0,
      );

      // Create SOS document
      String sosId = _firestore
          .collection('elders')
          .doc(currentUser.uid)
          .collection('sos_alerts')
          .doc()
          .id;

      SOSModel sosModel = SOSModel(
        id: sosId,
        elderId: currentUser.uid,
        elderName: elderData['name'],
        timestamp: DateTime.now(),
        location: location,
        mediaUrl: mediaUrl,
      );

      // Save SOS alert in Firestore
      await _firestore
          .collection('elders')
          .doc(currentUser.uid)
          .collection('sos_alerts')
          .doc(sosId)
          .set(sosModel.toMap());

      // Get caretaker IDs
      List<DocumentReference> caretakerRefs =
          List<DocumentReference>.from(elderData['caretakerIds'] ?? []);

      // Get FCM tokens for all caretakers
      List<String> caretakerTokens = [];
      for (DocumentReference caretakerRef in caretakerRefs) {
        DocumentSnapshot caretakerDoc = await caretakerRef.get();
        if (caretakerDoc.exists) {
          Map<String, dynamic> caretakerData =
              caretakerDoc.data() as Map<String, dynamic>;
          String? token = caretakerData['fcmToken'];
          if (token != null) {
            caretakerTokens.add(token);
          }
        }
      }

      // Send notifications to all caretakers
      if (caretakerTokens.isNotEmpty) {
        await _sendNotificationsToCaretakers(
          sosId: sosId,
          elderName: elderData['name'],
          tokens: caretakerTokens,
        );
      }

      return sosId;
    } catch (e) {
      print('Error creating SOS alert: $e');
      throw e;
    }
  }

  // Method to get all SOS alerts for an elder
  Future<List<SOSModel>> getElderSOSHistory(String elderId) async {
    try {
      QuerySnapshot sosSnapshot = await _firestore
          .collection('elders')
          .doc(elderId)
          .collection('sos_alerts')
          .orderBy('timestamp', descending: true)
          .get();

      return sosSnapshot.docs
          .map((doc) => SOSModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting elder SOS history: $e');
      throw e;
    }
  }

  // Method to get a specific SOS alert
  Future<SOSModel> getSOSAlert(String elderId, String sosId) async {
    try {
      DocumentSnapshot sosDoc = await _firestore
          .collection('elders')
          .doc(elderId)
          .collection('sos_alerts')
          .doc(sosId)
          .get();

      if (!sosDoc.exists) {
        throw Exception('SOS alert not found');
      }

      return SOSModel.fromMap(sosDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting SOS alert: $e');
      throw e;
    }
  }

  // Method to resolve an SOS alert
  Future<void> resolveSOSAlert(String elderId, String sosId) async {
    try {
      await _firestore
          .collection('elders')
          .doc(elderId)
          .collection('sos_alerts')
          .doc(sosId)
          .update({'resolved': true});
    } catch (e) {
      print('Error resolving SOS alert: $e');
      throw e;
    }
  }

  // Get current location
  Future<LocationData?> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check if permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Get location
    return await location.getLocation();
  }

  // Send notifications to caretakers
  Future<void> _sendNotificationsToCaretakers({
    required String sosId,
    required String elderName,
    required List<String> tokens,
  }) async {
    try {
      // This would typically be implemented as a Cloud Function
      // For now, we'll use a direct HTTP call to our function URL
      await http.post(
        Uri.parse(fcmSendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tokens': tokens,
          'data': {
            'sosId': sosId,
            'elderId': _auth.currentUser!.uid,
          },
          'notification': {
            'title': 'EMERGENCY: SOS Alert',
            'body': '$elderName has requested emergency assistance!',
          },
        }),
      );
    } catch (e) {
      print('Error sending notifications: $e');
      // Fail silently but log the error - we still want to create the SOS alert
      // even if notification sending fails
    }
  }
}
