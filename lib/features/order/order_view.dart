import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:shimmer/shimmer.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 234, 244),

      appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const Icon(Icons.arrow_back, color: Colors.black),
            titleSpacing: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Orders",
                  style: AppText.titleLarge.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              
              ],
            ),
          ), 
          body:  Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
            imageUrl:
                "https://cdni.iconscout.com/illustration/premium/thumb/no-orders-yet-illustration-svg-download-png-13391224.png",
            width: 230,
            height: 230,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                period: const Duration(milliseconds: 1000),
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error),
            ),
          ),
          
                    SizedBox(height: 20),
                    Text(
                      "No order yet",
                      style: AppText.titleLarge.copyWith(color: Colors.black),
                    ),
                    Text(
                      "Hungry? Place an order and it'll show here",
                      textAlign: TextAlign.center,
                      style: AppText.bodyMedium.copyWith(color: Colors.black,fontSize: 13),
                    ),

                  ],
                ),
              ),
          ),
    );
  }
}