import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/localization/google_map.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/home/home_view.dart';
import 'package:food_delivery_app/features/auth/location%20access/location_view.dart';
import 'package:food_delivery_app/features/auth/login/login_view.dart';
import 'package:food_delivery_app/features/auth/notification%20access/notification_view.dart';
import 'package:food_delivery_app/features/splash/onboarding/onboarding_view.dart';
import 'package:food_delivery_app/features/auth/signup/signup_view.dart';
import 'package:food_delivery_app/features/splash/splash_view.dart';

import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (_) => const SplashView(),
    AppRoutes.onBoarding: (_) => const OnboardingView(),
    AppRoutes.login: (_) =>  LoginView(),
    AppRoutes.signup: (_) => const SignupView(),
    AppRoutes.locationAccess: (_) => const LocationView(),
    AppRoutes.notificationAccess: (_) => const NotificationView(),
    AppRoutes.home: (_) =>  HomeView(),
    AppRoutes.bottomNavi: (_) => const BottomNavi(),
    AppRoutes.googleMap: (_) => const GoogleMapView(),


  };
}
