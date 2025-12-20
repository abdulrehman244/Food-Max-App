import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/PromoFixedBar.dart';
import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class PromoBottomSheet extends StatelessWidget {
  const PromoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.98,
        child: DraggableScrollableSheet(
          initialChildSize: 0.98,
          minChildSize: 0.6,
          maxChildSize: 0.98,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // 🔘 Drag Handle
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔥 HEADER
                    PromoFixedBar(
                      onTap: () {
                        Nav.back(context);
                      },
                      height: 100,
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: Consumer<HomeViewModel>(
                        builder: (context, vm, child) {
                          return ListView.builder(
                            controller: scrollController, // ⭐ MOST IMPORTANT
                            itemCount: vm.randomDiscount.length,
                            itemBuilder: (c, i) {
                              final r = vm.randomDiscount[i];
                              return RestaurantCard(
                                imageUrl: r.image,
                                title: r.name,
                                rating: "${r.rating} (5000+)",
                                time:
                                    "${r.deliveryTime} min • \$\$ • ${r.type}",
                                price: "From ${r.deliveryFee} With Saver",
                                restaurant: r,
                                container: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  height: 20,
                                  width: 165,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 248, 215, 220),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/png_images/discount_2.png",
                                        height: 14,
                                        width: 14,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        "30% off selected items",
                                        style: AppText.bodyLarge.copyWith(
                                          color: Colors.pink.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                width: double.infinity,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // 🔽 CONTENT
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
