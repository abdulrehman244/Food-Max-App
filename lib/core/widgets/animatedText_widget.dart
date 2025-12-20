import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const AnimatedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 🔥 Animated Hint Text
          if (controller.text.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child:
               AnimatedTextKit(
                repeatForever: true,
                pause: const Duration(milliseconds: 1000),
                animatedTexts: [
                  RotateAnimatedText(
                    'Search Pizza',
                    textStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  RotateAnimatedText(
                    'Search Burger',
                    textStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  RotateAnimatedText(
                    'Search Biryani',
                    textStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            
            
            ),

          // 🔍 Search Icon
          const Icon(Icons.search, color: Colors.grey),

          // 📝 TextField
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 35),
            ),
          ),
        ],
      ),
    );
  }
}
