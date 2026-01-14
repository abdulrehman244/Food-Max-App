import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/widgets/bottomSheet_widget.dart';

void showPromotionalPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 500,
              child: Material( // ✅ REQUIRED
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.pop(context);

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const PromoBottomSheet(),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/png_images/PP.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

           Positioned(
  top: 12,
  right: 12,
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 1),
          color: Colors.white
        ),
        child: const Icon(
          Icons.close,
          color: Colors.grey,
          size: 20,
        ),
      ),
    ),
  ),
),

          ],
        ),
      );
    },
  );
}
