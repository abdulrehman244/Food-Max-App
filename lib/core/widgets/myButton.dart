import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/config/theme/app_color.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';

class MyButton extends StatelessWidget {
  final dynamic title;
  final VoidCallback ontap;
  final Color? color;
  final String? iconPath;
  final TextStyle? textStyle;
  final Widget? child;

  const MyButton({
    super.key,
    required this.title,
    required this.ontap,
    this.color,
    this.iconPath,
    this.textStyle, this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color ??  AppColors.appColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // text
                Text(title, style: textStyle ?? AppText.bodyMedium),
                const SizedBox(width: 20), // spacing between icon & text
                // agar icon path diya gaya hai to show karo
                if (iconPath != null) ...[
                  SvgPicture.asset(
                    iconPath!,
                    height: 24,
                    width: 24,
                    color: Colors.white, // white icon
                  ),
                  const SizedBox(width: 20), // spacing between icon & text
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
