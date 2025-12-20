import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Background notification handler
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

  // Initialize notifications
  static Future<void> initializeNotification({bool requestPermission = false}) async {
    if (requestPermission) {
      await requestPermissions();
    }

    await _getFcmTokenAndSave();
    await _initializeLocalNotification();

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showFlutterNotification(message);
    });

    // App launch from notification
    await _handleAppLaunchFromNotification();
  }

  // Request permissions (iOS & Android)
  static Future<bool> requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Get FCM token and save to Firestore
  static Future<void> _getFcmTokenAndSave() async {
    String? token = await _firebaseMessaging.getToken();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (token != null && uid != null) {
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "fcmToken": token,
        "notificationsEnabled": true,
      }, SetOptions(merge: true));
    }
  }

  // Show Flutter local notification (for both foreground & background)
  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? n = message.notification;
    String title = n?.title ?? message.data["title"] ?? "Notification";
    String body = n?.body ?? message.data["body"] ?? "Message";

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      importance: Importance.high,
      priority: Priority.high,
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();

    NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }



  // Initialize local notifications
  static Future<void> _initializeLocalNotification() async {
    const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iosInit = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (response) {
      print("User tapped notification: ${response.payload}");
    });
  }



  // Handle app launch from notification
  static Future<void> _handleAppLaunchFromNotification() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("App opened from notification: ${initialMessage.data}");
    }
  }
}








