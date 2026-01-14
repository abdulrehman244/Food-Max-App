import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';

class ThemeViewModel extends ChangeNotifier {
  Color _appColor;

  ThemeViewModel() : _appColor = HiveService().getUserTheme();

  Color get appColor => _appColor;

  bool get isPink => _appColor == Colors.pink;

  void toggleTheme(bool isOn) {
    _appColor = isOn ? Colors.pink : Color(0xFFFF7622);
    notifyListeners();

    // 🔥 Save theme for user in Hive
    HiveService().saveUserTheme(_appColor);
  }

  void changeTheme(Color color) {
    _appColor = color;
    notifyListeners();

    // 🔥 Save theme for user in Hive
    HiveService().saveUserTheme(_appColor);
  }
}
