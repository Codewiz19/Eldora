// lib/services/fall_detection_service.dart
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/sos_model.dart';

class FallDetectionService {
  // Singleton pattern
  static final FallDetectionService _instance = FallDetectionService._internal();
  factory FallDetectionService() => _instance;
  FallDetectionService._internal();

  // Fall detection parameters
  final double _accelerationThreshold = 20.0; // m/s²
  final double _rotationThreshold = 2.5; // rad/s
  
  // Monitoring state
  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;
  
  // Stream subscriptions
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Callbacks
  Function? onFallDetected;
  Function? onSendingSOS;
  Function? onSOSSent;
  Function? onSOSCancelled;
  Function? onError;

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Start monitoring for falls
  void startMonitoring({
    required Function onFallDetected,
    required Function onSendingSOS,
    required Function onSOSSent,
    required Function onSOSCancelled,
    required Function onError,
  }) {
    if (_isMonitoring) return;
    
    this.onFallDetected = onFallDetected;
    this.onSendingSOS = onSendingSOS;
    this.onSOSSent = onSOSSent;
    this.onSOSCancelled = onSOSCancelled;
    this.onError = onError;
    
    _isMonitoring = true;
    
    // Start monitoring accelerometer
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Calculate total acceleration magnitude
      final double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      // Check if acceleration exceeds threshold
      if (acceleration > _accelerationThreshold) {
        _detectFall();
      }
    });
    
    // Start monitoring gyroscope
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      // Calculate total rotational movement
      final double rotation = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      // Check if rotation exceeds threshold
      if (rotation > _rotationThreshold) {
        _detectFall();
      }
    });
  }
  
  // Stop monitoring
  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _isMonitoring = false;
    
    // Clear callbacks
    onFallDetected = null;
    onSendingSOS = null;
    onSOSSent = null;
    onSOSCancelled = null;
    onError = null;
  }
  
  // Detect fall
  void _detectFall() {
    if (onFallDetected != null) {
      onFallDetected!();
    }
  }
  
  // Create and send SOS
  Future<void> sendSOS({
    required String elderId,
    required String elderName,
    String? emergencyContact,
  }) async {
    try {
      if (onSendingSOS != null) {
        onSendingSOS!();
      }
      
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
        elderId: elderId,
        elderName: elderName,
        timestamp: DateTime.now(),
        location: geoPoint,
        reason: "Fall detected automatically by sensors",
        resolved: false,
      );
      
      // Save to Firestore
      await _firestore.collection('sos_events').doc(sosId).set(sosModel.toMap());
      
      if (onSOSSent != null) {
        onSOSSent!(sosId);
      }
    } catch (e) {
      if (onError != null) {
        onError!(e.toString());
      }
    }
  }
  
  // Cancel SOS process
  void cancelSOS() {
    if (onSOSCancelled != null) {
      onSOSCancelled!();
    }
  }
  
  // Adjust sensitivity
  void setSensitivity({double? acceleration, double? rotation}) {
    if (acceleration != null) {
      _accelerationThreshold = acceleration;
    }
    if (rotation != null) {
      _rotationThreshold = rotation;
    }
  }
}