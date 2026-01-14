import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class Itemview extends StatelessWidget {
  const Itemview({super.key});

  /// 🔒 Screen-wise shuffled cache (ONLY HERE)
  static final Map<String, List<RestaurantModel>> _screenCache = {};

  /// 🔥 shuffle + limit 10 (only once per screen)
  List<RestaurantModel> _getScreenRestaurants(
    String screenName,
    List<RestaurantModel> source,
  ) {
    final key = screenName.toLowerCase();

    if (_screenCache.containsKey(key)) {
      return _screenCache[key]!;
    }

    final shuffled = List<RestaurantModel>.from(source)..shuffle();
    final limited = shuffled.take(10).toList();

    _screenCache[key] = limited;
    return limited;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              // 🔁 screen close → cache clear
              _screenCache.remove(model.selectedItem.toLowerCase());
              Nav.back(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          titleSpacing: 0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
          title: Text(
            model.selectedItem.isEmpty ? "Loading..." : model.selectedItem,
            style: AppText.titleLarge.copyWith(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// ================= OFFERS =================
              model.selectedItem.toLowerCase() == "offers"
                  ? Column(
                      children: [
                        SizedBox(
                          height: 290,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: model.randomDiscount.length,
                            itemBuilder: (c, i) {
                              final r = model.randomDiscount[i];
                              return RestaurantCard(
                                imageUrl: r.image,
                                title: r.name,
                                rating: "${r.rating} (5000+)",
                                time:
                                    "${r.deliveryTime} min • \$\$ • ${r.type}",
                                price: "From ${r.deliveryFee} With Saver",
                                restaurant: r,
                                container: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 20,
                                      width: 165,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(
                                          255,
                                          248,
                                          215,
                                          220,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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

                                    SizedBox(width: 10),

                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 20,
                                      // width: 50,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(
                                          255,
                                          248,
                                          215,
                                          220,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "free Delivery",
                                        style: AppText.bodyLarge.copyWith(
                                          color: Colors.pink.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          height: 10,
                          color: Colors.grey.shade300,
                        ),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: model.randomNew.length,
                          itemBuilder: (c, i) {
                            final r = model.randomNew[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RestaurantCard(
                                width: double.infinity,
                                imageUrl: r.image,
                                title: r.name,
                                rating: "${r.rating} (5000+)",
                                time: "${r.deliveryTime} min • \$\$ • ${r.type}",
                                price: "From ${r.deliveryFee} With Saver",
                                restaurant: r,
                                container: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 20,
                                      width: 165,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 248, 215, 220),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              
                                    SizedBox(width: 10),
                              
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 20,
                                      // width: 50,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 248, 215, 220),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "free Delivery",
                                        style: AppText.bodyLarge.copyWith(
                                          color: Colors.pink.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  /// ================= NORMAL SCREENS =================
                  : Builder(
                      builder: (_) {
                        final screenRestaurants = _getScreenRestaurants(
                          model.selectedItem,
                          model.restaurants,
                        );

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: screenRestaurants.length, // 🔥 always 10
                          itemBuilder: (c, i) {
                            final r = screenRestaurants[i];
                            return RestaurantCard(
                              width: double.infinity,
                              imageUrl: r.image,
                              title: r.name,
                              rating: "${r.rating} (5000+)",
                              time: "${r.deliveryTime} min • \$\$ • ${r.type}",
                              price: "From ${r.deliveryFee} With Saver",
                              restaurant: r,
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
