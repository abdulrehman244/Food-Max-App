import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:lottie/lottie.dart';

class OnboardingWidget extends StatelessWidget {
  final String lottie;
  final String title;
  final String description;
  final Color color;
  const OnboardingWidget({
    super.key,
    required this.lottie,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: color,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(lottie),
            SizedBox(height: 30),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.bodyLarge.copyWith(color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,

              style: AppText.bodyMedium.copyWith(color: Colors.black),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
