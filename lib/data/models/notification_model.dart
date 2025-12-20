import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  String title;
  String body;
  bool read;
  DateTime timestamp;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    this.read = false,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      read: map['read'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'read': read,
      'timestamp': timestamp,
    };
  }
}
