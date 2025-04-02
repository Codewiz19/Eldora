// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/elder_model.dart';
import '../models/caretaker_model.dart';

import 'package:flutter/material.dart';

// Add to lib/services/auth_service.dart
import '../services/fcm_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FCMService _fcmService = FCMService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Initialize FCM after successful sign in
      await _fcmService.initialize(context);

      return credentials;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    // Clear FCM token before signing out
    final User? user = currentUser;
    if (user != null) {
      String? userType = await getUserType(user.uid);
      if (userType == 'elder') {
        await _firestore.collection('elders').doc(user.uid).update({
          'fcmToken': null,
        });
      } else if (userType == 'caretaker') {
        await _firestore.collection('caretakers').doc(user.uid).update({
          'fcmToken': null,
        });
      }
    }

    return await _auth.signOut();
  }

  // Create a new elder document
  Future<void> createElderDocument(
    String uid,
    String name,
    String email,
    int age,
    String gender,
    BuildContext context,
  ) async {
    await _firestore.collection('elders').doc(uid).set({
      'name': name,
      'email': email,
      'userType': 'elder',
      'age': age,
      'gender': gender,
      'caretakerIds': [],
      'medications': [],
      'fcmToken': null, // Will be updated by FCM service
    });

    // Initialize FCM to update the token
    await _fcmService.initialize(context);
  }

  // Create a new caretaker document
  Future<void> createCaretakerDocument(
    String uid,
    String name,
    String email,
    BuildContext context,
  ) async {
    await _firestore.collection('caretakers').doc(uid).set({
      'name': name,
      'email': email,
      'userType': 'caretaker',
      'elderIds': [],
      'fcmToken': null, // Will be updated by FCM service
    });

    // Initialize FCM to update the token
    await _fcmService.initialize(context);
  }

  // Get user type
  Future<String?> getUserType(String uid) async {
    // Check if user exists in elders collection
    var elderDoc = await _firestore.collection('elders').doc(uid).get();
    if (elderDoc.exists) {
      return 'elder';
    }

    // Check if user exists in caretakers collection
    var caretakerDoc = await _firestore.collection('caretakers').doc(uid).get();
    if (caretakerDoc.exists) {
      return 'caretaker';
    }

    return null;
  }

  // Get elder details
  Future<ElderModel?> getElderDetails(String uid) async {
    var doc = await _firestore.collection('elders').doc(uid).get();
    if (doc.exists) {
      return ElderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Get caretaker details
  Future<CaretakerModel?> getCaretakerDetails(String uid) async {
    var doc = await _firestore.collection('caretakers').doc(uid).get();
    if (doc.exists) {
      return CaretakerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Get caretaker by email
  Future<DocumentReference?> getCaretakerRefByEmail(String email) async {
    var querySnapshot = await _firestore
        .collection('caretakers')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.reference;
    }
    return null;
  }

  // // Link caretaker to elder
  // Future<bool> linkCaretakerToElder(
  //     String elderUid, String caretakerEmail) async {
  //   try {
  //     // Get caretaker reference
  //     DocumentReference? caretakerRef =
  //         await getCaretakerRefByEmail(caretakerEmail);
  //     if (caretakerRef == null) {
  //       return false;
  //     }

  //     // Get elder reference
  //     DocumentReference elderRef =
  //         _firestore.collection('elders').doc(elderUid);

  //     // Update elder document to add caretaker reference
  //     await _firestore.runTransaction((transaction) async {
  //       // Get elder to check if caretaker already linked
  //       DocumentSnapshot elderSnapshot = await transaction.get(elderRef);
  //       List<dynamic> caretakerIds =
  //           elderSnapshot.get('caretakerIds') as List<dynamic>;

  //       // Check if already linked
  //       bool alreadyLinked =
  //           caretakerIds.any((ref) => ref.path == caretakerRef.path);
  //       if (!alreadyLinked) {
  //         caretakerIds.add(caretakerRef);
  //         transaction.update(elderRef, {'caretakerIds': caretakerIds});
  //       }

  //       // Update caretaker document to add elder reference
  //       DocumentSnapshot caretakerSnapshot =
  //           await transaction.get(caretakerRef);
  //       List<dynamic> elderIds =
  //           caretakerSnapshot.get('elderIds') as List<dynamic>;

  //       alreadyLinked = elderIds.any((ref) => ref.path == elderRef.path);
  //       if (!alreadyLinked) {
  //         elderIds.add(elderRef);
  //         transaction.update(caretakerRef, {'elderIds': elderIds});
  //       }
  //     });

  //     return true;
  //   } catch (e) {
  //     print('Error linking caretaker: $e');
  //     return false;
  //   }
  // }
  //
  // Link caretaker to elder
  Future<bool> linkCaretakerToElder(
      String elderUid, String caretakerEmail) async {
    try {
      // Get caretaker document by email
      final caretakerQuery = await _firestore
          .collection('caretakers')
          .where('email', isEqualTo: caretakerEmail)
          .limit(1)
          .get();

      if (caretakerQuery.docs.isEmpty) {
        print('No caretaker found with email: $caretakerEmail');
        return false;
      }

      final caretakerDoc = caretakerQuery.docs.first;
      final caretakerRef = caretakerDoc.reference;
      final elderRef = _firestore.collection('elders').doc(elderUid);

      // Get current data for both documents
      final elderDoc = await elderRef.get();

      if (!elderDoc.exists) {
        print('Elder document does not exist for uid: $elderUid');
        return false;
      }

      // Update elder document first
      List<dynamic> currentCaretakerIds =
          List.from(elderDoc.data()?['caretakerIds'] ?? []);
      bool alreadyLinked =
          currentCaretakerIds.any((ref) => ref.path == caretakerRef.path);

      if (!alreadyLinked) {
        currentCaretakerIds.add(caretakerRef);
        await elderRef.update({'caretakerIds': currentCaretakerIds});
      }

      // Update caretaker document
      List<dynamic> currentElderIds =
          List.from(caretakerDoc.data()?['elderIds'] ?? []);
      alreadyLinked = currentElderIds.any((ref) => ref.path == elderRef.path);

      if (!alreadyLinked) {
        currentElderIds.add(elderRef);
        await caretakerRef.update({'elderIds': currentElderIds});
      }

      return true;
    } catch (e) {
      print('Error linking caretaker (fixed): $e');
      return false;
    }
  }
}
