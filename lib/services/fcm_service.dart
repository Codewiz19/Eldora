import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Singleton pattern
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  Future<void> initialize(BuildContext context) async {
    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get and store FCM token
    await _getAndStoreToken();

    // Listen for token refresh
    _listenForTokenRefresh();

    // Set up message handlers
    _setupMessageHandlers(context);
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        final String? payload = response.payload;
        if (payload != null) {
          print('Notification payload: $payload');
          // Navigate to SOS details page
        }
      },
    );

    // Create high importance notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'sos_alert_channel',
        'SOS Alerts',
        description: 'This channel is used for SOS alerts',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('sos_alarm'),
        enableVibration: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Modify your FCMService._getAndStoreToken method
  Future<void> _getAndStoreToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // First check if user is an elder
        DocumentSnapshot elderDoc = await FirebaseFirestore.instance
            .collection('elders')
            .doc(currentUser.uid)
            .get();

        if (elderDoc.exists) {
          await FirebaseFirestore.instance
              .collection('elders')
              .doc(currentUser.uid)
              .update({'fcmToken': token});
          print('Updated elder FCM token: $token');
          return;
        }

        // If not an elder, check if caretaker
        DocumentSnapshot caretakerDoc = await FirebaseFirestore.instance
            .collection('caretakers')
            .doc(currentUser.uid)
            .get();

        if (caretakerDoc.exists) {
          await FirebaseFirestore.instance
              .collection('caretakers')
              .doc(currentUser.uid)
              .update({'fcmToken': token});
          print('Updated caretaker FCM token: $token');
          return;
        }
      }
    }
  }

  void _listenForTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Check if user is an elder
        DocumentSnapshot elderDoc = await FirebaseFirestore.instance
            .collection('elders')
            .doc(currentUser.uid)
            .get();

        if (elderDoc.exists) {
          await FirebaseFirestore.instance
              .collection('elders')
              .doc(currentUser.uid)
              .update({'fcmToken': token});
          print('Refreshed elder FCM token: $token');
          return;
        }

        // If not an elder, check if caretaker
        DocumentSnapshot caretakerDoc = await FirebaseFirestore.instance
            .collection('caretakers')
            .doc(currentUser.uid)
            .get();

        if (caretakerDoc.exists) {
          await FirebaseFirestore.instance
              .collection('caretakers')
              .doc(currentUser.uid)
              .update({'fcmToken': token});
          print('Refreshed caretaker FCM token: $token');
          return;
        }
      }
    }).onError((err) {
      print('Error getting refreshed token: $err');
    });
  }

  void _setupMessageHandlers(BuildContext context) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Show a notification when in foreground
      if (notification != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'sos_alert_channel',
              'SOS Alerts',
              channelDescription: 'This channel is used for SOS alerts',
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon,
              enableVibration: true,
              ongoing: true, // Makes notification persistent (non-dismissible)
              fullScreenIntent: true, // This will show even on lock screen
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.critical,
            ),
          ),
          payload: message.data['sosId'],
        );
      }
    });

    // Handle background/terminated messages when app is opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');

      // Navigate to SOS details page with sosId
      if (message.data.containsKey('sosId')) {
        Navigator.pushNamed(
          context,
          '/sos-details',
          arguments: message.data['sosId'],
        );
      }
    });
  }

  // Call this method when the app first starts
  Future<void> checkInitialMessage(BuildContext context) async {
    // Get initial message if app was terminated and opened via notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      if (initialMessage.data.containsKey('sosId')) {
        Navigator.pushNamed(
          context,
          '/sos-details',
          arguments: initialMessage.data['sosId'],
        );
      }
    }
  }
}
