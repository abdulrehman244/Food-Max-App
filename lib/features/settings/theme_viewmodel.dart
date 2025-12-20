import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_color.dart';

class ThemeViewModel extends ChangeNotifier {
  bool isDarkMode = false;

  bool isSelected = false;

  Color _appColor = AppColors.appColor;
  Color get appColor => _appColor;

  void toggleTheme(bool value) {
    isDarkMode = value;

    // toggle color
    _appColor = isDarkMode
        ? Color.fromARGB(255, 233, 30, 99) // red example
        : AppColors.appColor; // default

    notifyListeners();
  }

  void toggle() {
    isSelected = !isSelected;
    notifyListeners();
  }
}
