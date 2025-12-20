import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NotificationAdminViewModel extends ChangeNotifier {
  bool loading = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  // Server Key Firebase Console → Cloud Messaging
  final String serverKey = "AAAA..."; // <-- yahan apna Server Key dalna

  // Send notification to all users
  Future<void> sendNotificationToAllUsers() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) return;

    loading = true;
    notifyListeners();

    try {
      // 1️⃣ Firestore se sab users ke tokens fetch karo
      final snapshot = await FirebaseFirestore.instance.collection("users").get();
      final tokens = snapshot.docs
          .map((doc) => doc['fcmToken'] as String?)
          .where((token) => token != null)
          .toList();

      // 2️⃣ HTTP POST request har token ko
      for (var token in tokens) {
        await http.post(
          Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonEncode({
            "to": token,
            "notification": {"title": title, "body": body},
            "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"}
          }),
        );
      }
    } catch (e) {
      print("Error sending notification: $e");
    }

    loading = false;
    notifyListeners();
  }

  void clearFields() {
    titleController.clear();
    bodyController.clear();
  }
}
