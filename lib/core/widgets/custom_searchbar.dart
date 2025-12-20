import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';

class CustomSearchbar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  final double height;

  const CustomSearchbar({
    Key? key,
    this.controller,
    this.hintText = "Search",
    this.onChanged,
    this.height = 45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final bottomNaviState = context
            .findAncestorStateOfType<BottomNaviState>();
        if (bottomNaviState != null) {
          bottomNaviState.currentIndex.value = 2; // Search screen
        }
      },
      child:
       Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade600),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                enabled: false,
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  // suffixIcon: lottie,
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  hintText: hintText,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: AppText.bodyMedium.copyWith(color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      ),
    
    
    );
  }
}
