import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/order/order_view.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:lottie/lottie.dart';

class Successfully extends StatelessWidget {
  const Successfully({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, animation, __) => BottomNavi(),
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lottie/scooterguy.json"),
            Text(
              "Congratulations",
              style: AppText.titleLarge.copyWith(color: Colors.black),
            ),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: MyButton(
                title: "Track your Order",
                ontap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      reverseTransitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (_, animation, __) => OrderView(),
                      transitionsBuilder: (_, animation, secondaryAnimation, child) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          ),
                        );
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
