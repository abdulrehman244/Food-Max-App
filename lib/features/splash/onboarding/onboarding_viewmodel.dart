import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/widgets/onboarding_pages.dart';
import 'package:food_delivery_app/features/auth/login/login_view.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class OnboardingViewmodel extends ChangeNotifier {
  final LiquidController liquidController = LiquidController();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  OnboardingViewmodel() {
    /// Delay first frame → prevents first-swipe jank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  final List<Widget> pages = [
    const OnboardingWidget(
      lottie: "assets/lottie/phone.json",
      title: "All your favorites",
      description:
          "Get all your loved foods in one once\nplace you just place the order we do the rest",
      color: Color(0xFFFF7622),
    ),
    const OnboardingWidget(
      lottie: "assets/lottie/cheflottie.json",
      title: "Order from\nchoosen chef",
      description:
          "Get all your loved foods in one once\nplace you just place the order we do the rest",
      color: Color(0xFFFDD835),
    ),
    const OnboardingWidget(
      lottie: "assets/lottie/scooterguy.json",
      title: "Free delivery offers",
      description:
          "Get all your loved foods in one once\nplace you just place the orer we do the rest",
      color: Colors.white,
    ),
  ];

  /// PAGE CHANGE (smooth & stable)
  void onPageChanged(int index) {
    if (_currentPage == index) return; // Prevent unnecessary rebuilds
    _currentPage = index;
    notifyListeners();
  }

  /// NEXT BUTTON
  void nextPage(BuildContext context) {
    if (_currentPage < pages.length - 1) {
      liquidController.animateToPage(
        page: _currentPage + 1,
        duration: 500, // smooth animation
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) =>  LoginView()),
        (Route<dynamic> route) => false,
      );
    }
  }

  /// SKIP BUTTON
  void skipPages(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) =>  LoginView()),
      (Route<dynamic> route) => false,
    );
  }
}
