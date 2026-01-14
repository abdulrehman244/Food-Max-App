import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class AnimatedSearchHint extends StatelessWidget {
  const AnimatedSearchHint({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
      child: AnimatedTextKit(
        repeatForever: true,
        pause: const Duration(milliseconds: 100),
        animatedTexts: [
          RotateAnimatedText('Search for Restaurants and Groceries'),
          RotateAnimatedText('Search Beef Burgers'),
          RotateAnimatedText('Search California Pizza'),
          RotateAnimatedText('Search deals'),
          RotateAnimatedText('Search for Kababjees Fried Chicken'),
        ],
      ),
    );
  }
}

class CustomSearchbar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final double height;

  const CustomSearchbar({
    Key? key,
    this.controller,
    this.onChanged,
    this.height = 45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    return GestureDetector(
      onTap: () {
        final bottomNaviState = context
            .findAncestorStateOfType<BottomNaviState>();
        if (bottomNaviState != null) {
          bottomNaviState.currentIndex.value = 2;
        }
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade600),
            const SizedBox(width: 10),

            /// 🔥 Animated hint overlay
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // REAL TEXTFIELD (disabled)
                  TextField(
                    enabled: false,
                    controller: controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),

                  // ANIMATED HINT
                  vm.isRestaurantLoading ? 
                  // SizedBox()
                  Text("Search for Restaurants and Groceries",style: TextStyle(fontSize: 16, color: Colors.grey.shade700),)
                  
                   : Positioned(left: 5, child: const AnimatedSearchHint()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:food_delivery_app/config/theme/app_text.dart';
// import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';

// class CustomSearchbar extends StatelessWidget {
//   final TextEditingController? controller;
//   final String hintText;
//   final Function(String)? onChanged;
//   final double height;

//   const CustomSearchbar({
//     Key? key,
//     this.controller,
//     this.hintText = "Search",
//     this.onChanged,
//     this.height = 45,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         final bottomNaviState = context
//             .findAncestorStateOfType<BottomNaviState>();
//         if (bottomNaviState != null) {
//           bottomNaviState.currentIndex.value = 2; // Search screen
//         }
//       },
//       child:
//        Container(
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(25),
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 15),
//         child: Row(
//           children: [
//             Icon(Icons.search, color: Colors.grey.shade600),
//             SizedBox(width: 10),
//             Expanded(
//               child: TextField(
//                 enabled: false,
//                 controller: controller,
//                 onChanged: onChanged,
//                 decoration: InputDecoration(
//                   // suffixIcon: lottie,
//                   hintStyle: TextStyle(color: Colors.grey.shade700),
//                   hintText: hintText,
//                   border: InputBorder.none,
//                   isDense: true,
//                 ),
//                 style: AppText.bodyMedium.copyWith(color: Colors.grey.shade800),
//               ),
//             ),
//           ],
//         ),
//       ),
    
    
//     );
//   }
// }
