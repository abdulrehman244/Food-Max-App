import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/splash/onboarding/onboarding_viewmodel.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewmodel>(
      builder: (context, vm, child) {
        return Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              /// 🔥 Ultra Smooth LiquidSwipe
              LiquidSwipe(
                pages: vm.pages,
                liquidController: vm.liquidController,
                enableLoop: false,
                fullTransitionValue: 500, // Lower = smoother
                waveType: WaveType.liquidReveal,
                ignoreUserGestureWhileAnimating: true,
                onPageChangeCallback: vm.onPageChanged,
                slideIconWidget: vm.currentPage == vm.pages.length - 1
                    ? null
                    : const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                      ),
              ),

              /// 🔥 Super Smooth Dots Indicator
              Positioned(
                bottom: 150,
                child: AnimatedSmoothIndicator(
                  activeIndex: vm.currentPage,
                  count: vm.pages.length,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 11,
                    dotWidth: 11,
                    spacing: 8,
                    expansionFactor: 4,
                    activeDotColor: Colors.black,
                    dotColor: Color(0xFFBDBDBD),
                  ),
                ),
              ),

              /// 🔥 Next + Skip Buttons (Repaint-optimized)
              Positioned(
                bottom: 40,
                left: 30,
                right: 30,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        title: vm.currentPage == vm.pages.length - 1
                            ? "Get Started"
                            : "Next",
                        textStyle: AppText.bodyMedium.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        color: Colors.black,
                        ontap: () => vm.nextPage(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => vm.skipPages(context),
                      child: const Text(
                        "Skip",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
