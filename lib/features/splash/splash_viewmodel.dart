import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/routes/app_routes.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';

class SplashViewModel extends ChangeNotifier {
  bool _showSecondImage = false;
  bool get showSecondImage => _showSecondImage;

  Future<void> startAnimation(BuildContext context) async {
    // Fade-in animation
    await Future.delayed(const Duration(milliseconds: 500));
    _showSecondImage = true;
    notifyListeners();

    // Splash delay
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = HiveService().isUserLoggedIn();

    if (!context.mounted) return; // 🔥 SAFE

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? AppRoutes.bottomNavi : AppRoutes.onBoarding,
    );
  }
}