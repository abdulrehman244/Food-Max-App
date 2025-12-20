import 'package:flutter/material.dart';

class FoodCatogary extends StatelessWidget {
  final String title;
  const FoodCatogary({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(20)
        ),
      ),
      Text(title)]);
  }
}
