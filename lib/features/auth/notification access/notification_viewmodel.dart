import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/notification_service.dart';

class NotificationViewmodel extends ChangeNotifier {
  bool loading = false;

  // Button press ke liye
  Future<bool> allowNotification() async {
    loading = true;
    notifyListeners();

    bool allowed = await NotificationService.requestPermissions();

    if (allowed) {
      await NotificationService.initializeNotification(requestPermission: false);
    }

    loading = false;
    notifyListeners();

    return allowed;
  }
}







// import 'package:flutter/material.dart';
// import 'package:food_delivery_app/core/services/notification_service.dart';

// class NotificationViewmodel extends ChangeNotifier {
//   bool loading = false;

//   Future<bool> allowNotification() async {
//     loading = true;
//     notifyListeners();

//     bool allowed = await NotificationService.requestPermissions();

//     if (allowed) {
//       await NotificationService.initializeNotification();
//     }

//     loading = false;
//     notifyListeners();

//     return allowed;
//   }
// }
