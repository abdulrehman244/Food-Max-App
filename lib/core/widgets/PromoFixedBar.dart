// ignore: file_names
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class PromoFixedBar extends StatefulWidget {
  final VoidCallback? onTimeUp; // new
  final VoidCallback onTap;
  Widget? icon;
  double? height;

   PromoFixedBar({super.key, required this.onTap,this.icon,this.height,this.onTimeUp});

  @override
  State<PromoFixedBar> createState() => _PromoFixedBarState();
}

class _PromoFixedBarState extends State<PromoFixedBar> {
  Timer? _timer;
  int _seconds = 40 * 60;

void startTimer() {
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (_seconds > 0) {
      setState(() {
        _seconds--;
      });
    } else {
      _timer?.cancel();
      if (widget.onTimeUp != null) {
        widget.onTimeUp!(); // 👈 notify parent to hide
      }
    }
  });
}


  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = secs.toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr";
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
        decoration: BoxDecoration(
          color: const Color(0xffFDECEF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Lottie.asset("assets/lottie/flash_1.json", height: 50, width: 50),
            const SizedBox(width: 10),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Save 25%",
                    style: AppText.titleLarge.copyWith(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Flash Deals: limited time offers",
                    style: AppText.bodyMedium.copyWith(
                      color: Colors.pink.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // TIMER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.shade700,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                (_seconds ~/ 60).toString().padLeft(2, '0'), // minutes
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                ":",
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.shade700,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                (_seconds % 60).toString().padLeft(2, '0'), // seconds
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                 InkWell(onTap: () {}, child: widget.icon ?? SizedBox()),
                SizedBox(height: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


