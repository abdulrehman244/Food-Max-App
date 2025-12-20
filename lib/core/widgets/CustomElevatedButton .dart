import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  // Styling
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;

  // Size
  final double? width;
  final double? height;

  // Text
  final TextStyle? textStyle;

  // Border
  final BorderSide? borderSide;

  // Icon
  final IconData? icon;
  final double iconSize;
  final double iconSpacing;

  // Loading
  final bool isLoading;
  final Widget? loadingWidget;

  const CustomElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderRadius = 14,
    this.elevation = 2,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.width,
    this.height = 50,
    this.textStyle,
    this.borderSide,
    this.icon,
    this.iconSize = 20,
    this.iconSpacing = 8,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor:
              disabledBackgroundColor ?? Colors.grey.shade400,
          disabledForegroundColor:
              disabledForegroundColor ?? Colors.white70,
          elevation: elevation,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        child: isLoading
            ? loadingWidget ??
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(
        title,
        style: textStyle ??
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize),
        SizedBox(width: iconSpacing),
        Text(
          title,
          style: textStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
