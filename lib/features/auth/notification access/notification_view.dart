import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:lottie/lottie.dart';
import 'notification_viewmodel.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationViewmodel>(
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/lottie/Notification.json"),

                model.loading
                    ? Lottie.asset(
                        "assets/lottie/loader.json",
                        height: 70,
                        width: 70,
                      )
                    : MyButton(
                        title: "Access NOTIFICATION",
                        textStyle: AppText.bodyLarge.copyWith(fontSize: 18),
                        ontap: () async {
                          bool allowed = await model.allowNotification();
                          if (allowed) {
                            Nav.toAnimatedReplacement(context, BottomNavi());
                          }
                        },
                      ),

                SizedBox(height: 30),

                Text(
                  "Stay Updated!",
                  textAlign: TextAlign.center,
                  style: AppText.bodyLarge.copyWith(color: Colors.black),
                ),
                Text(
                  "Allow notifications to get real-time updates about your orders, offers, and delivery status.",
                  textAlign: TextAlign.center,
                  style: AppText.bodyMedium.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:food_delivery_app/config/routes/app_routes.dart';
// import 'package:food_delivery_app/config/theme/app_color.dart';
// import 'package:food_delivery_app/config/theme/app_text.dart';
// import 'package:food_delivery_app/core/widgets/myButton.dart';
// import 'package:lottie/lottie.dart';
// import 'notification_viewmodel.dart';

// class NotificationView extends StatelessWidget {
//   const NotificationView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final model = Provider.of<NotificationViewmodel>(context);

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         actions: [
//           GestureDetector(
//             onTap: () {
//               Navigator.pushReplacementNamed(context, AppRoutes.bottomNavi);
//             },
//             child: Text(
//               "Skip",
//               style: AppText.bodyMedium.copyWith(color: AppColors.appColor),
//             ),
//           ),
//           SizedBox(width: 20),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset("assets/lottie/Notification.json"),

//             model.loading
//                 ? CircularProgressIndicator()
//                 : MyButton(
//                     title: "Access NOTIFICATION",
//                     textStyle: AppText.bodyLarge.copyWith(fontSize: 18),
//                     ontap: () async {
//                       bool allowed = await model.allowNotification();
//                       if (allowed) {
//                         Navigator.pushReplacementNamed(
//                             context, AppRoutes.bottomNavi);
//                       }
//                     },
//                   ),

//             SizedBox(height: 30),

//             Text(
//               "Stay Updated!",
//               textAlign: TextAlign.center,
//               style: AppText.bodyLarge.copyWith(color: Colors.black),
//             ),
//             Text(
//               "Allow notifications to get real-time updates about your orders, offers, and delivery status.",
//               textAlign: TextAlign.center,
//               style: AppText.bodyMedium.copyWith(color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
