// lib/screens/elder/sos_button_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/sos_model.dart';
import '../../widgets/fall_detection_widget.dart';

class SOSButtonScreen extends StatefulWidget {
  const SOSButtonScreen({Key? key}) : super(key: key);

  @override
  State<SOSButtonScreen> createState() => _SOSButtonScreenState();
}

class _SOSButtonScreenState extends State<SOSButtonScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _userName = '';
  String _userId = '';
  String _emergencyContact = '';
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user ID
      final user = _auth.currentUser;
      if (user != null) {
        // Get user data from Firestore
        final userData = await _firestore.collection('users').doc(user.uid).get();
        
        final prefs = await SharedPreferences.getInstance();
        
        setState(() {
          _userId = user.uid;
          _userName = userData.data()?['name'] ?? user.displayName ?? 'User';
          _emergencyContact = userData.data()?['emergencyContact'] ?? prefs.getString('emergencyContact') ?? '';
        });
        
        // Save user data to shared preferences for offline access
        prefs.setString('elderName', _userName);
        prefs.setString('elderId', _userId);
        if (_emergencyContact.isNotEmpty) {
          prefs.setString('emergencyContact', _emergencyContact);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendSOS() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // Create GeoPoint for Firestore
      GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);
      
      // Generate a unique ID for the SOS
      String sosId = const Uuid().v4();
      
      // Create SOS model
      SOSModel sosModel = SOSModel(
        id: sosId,
        elderId: _userId,
        elderName: _userName,
        timestamp: DateTime.now(),
        location: geoPoint,
        reason: "Emergency button pressed manually",
        resolved: false,
      );
      
      // Save to Firestore
      await _firestore.collection('sos_events').doc(sosId).set(sosModel.toMap());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS alert sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Help'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Hello, $_userName',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 40),
                    
                    // Fall detection widget
                    FallDetectionWidget(
                      elderId: _userId,
                      elderName: _userName,
                      emergencyContact: _emergencyContact,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // SOS button
                    const Text(
                      'Press the button below in case of emergency',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _sendSOS,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Your emergency contacts will be notified immediately',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}