import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<bool> requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // ================= INIT =================
  static Future<void> initializeNotification({
    bool requestPermission = true,
  }) async {
    if (requestPermission) {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
    }

    await _createNotificationChannel();
    await _initLocalNotification();
    await _saveFcmToken();

    // 🔔 FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showSimpleNotification(
        title: message.notification?.title ?? "Notification",
        body: message.notification?.body ?? "Message",
      );
    });

    // 🔔 APP OPEN FROM BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Opened from notification");
    });
  }

  // ================= LOCAL INIT =================
  static Future<void> _initLocalNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings();

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  // ================= CHANNEL =================
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_channel',
      'Orders',
      importance: Importance.high,
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // ================= SAVE TOKEN =================
  static Future<void> _saveFcmToken() async {
    final token = await _fcm.getToken();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (token != null && uid != null) {
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "fcmToken": token,
      }, SetOptions(merge: true));
    }
  }

  // ================= SIMPLE NOTIFICATION =================
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'order_channel',
          'Orders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }




static Future<void> showEachItemNotification({
  required String restaurantName,
  required List items,
}) async {
  for (int i = 0; i < items.length; i++) {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + i, // 🔥 unique id
      "Order Placed ✅",
      "${items[i]['name']} • $restaurantName",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'order_channel',
          'Orders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}











  // ================= ORDER PLACED =================
  // static Future<void> showOrderPlacedNotification({
  //   required String restaurantName,
  //   required List items,
  // }) async {
  //   /// 👉 item names list
  //   final List<String> lines = items
  //       .map<String>((e) => e["name"].toString())
  //       .toList();

  //   final inboxStyle = InboxStyleInformation(
  //     lines, // 👈 ye lines arrow press par show hoti hain
  //     contentTitle: "Order placed at $restaurantName 🎉",
  //     summaryText: "${items.length} items ordered",
  //   );

  //   final androidDetails = AndroidNotificationDetails(
  //     'order_channel',
  //     'Orders',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     styleInformation: inboxStyle, // 🔥 MAIN MAGIC
  //   );

  //   final details = NotificationDetails(android: androidDetails);

  //   await _local.show(
  //     DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //     "Order Placed ✅",
  //     "Tap to view items",
  //     details,
  //   );
  // }










  @pragma('vm:entry-point')
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await NotificationService.showSimpleNotification(
      title: message.notification?.title ?? "Notification",
      body: message.notification?.body ?? "Message",
    );
  }
}
