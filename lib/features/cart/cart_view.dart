import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/check_out/confirm_orderview.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final vm = context.watch<CartViewModel>();

    return Scaffold(
      backgroundColor: vm.cart.isEmpty ? Colors.white : Colors.grey.shade100,

      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Divider(
            thickness: 0.7,
            height: 0,
            color: Colors.grey.shade400,
            endIndent: 0,
            indent: 0,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "All Carts",
              style: AppText.titleLarge.copyWith(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            Row(
              children: [
                Text(
                  "Deliver to: ",
                  style: AppText.bodyMedium.copyWith(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: Text(
                    homeVm.userAddress.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyLarge.copyWith(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Consumer<CartViewModel>(
        builder: (context, cartVm, _) {
          if (cartVm.cart.isEmpty) {
            return _emptyCart(context);
          }

          final vm = context.watch<CartViewModel>();
final restaurants = vm.cart;


          return 
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final rest = Map<String, dynamic>.from(restaurants[index]);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// RESTAURANT HEADER
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            rest["restaurantImage"],
                            height: 45,
                            width: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rest["restaurantName"],
                            style: AppText.titleLarge.copyWith(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.more_horiz_outlined, size: 35),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isDismissible: false,
                              enableDrag: false,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) {
                                return _customBottomSheet(
                                  context.read<CartViewModel>(),
                                  context,
                                  rest["restaurantId"], // restaurantId
                                  null, // agar sirf restaurant delete karna ho
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        ...rest["items"].map<Widget>((item) {
                          final mapItem = Map<String, dynamic>.from(item);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(mapItem["image"]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // const SizedBox(width: 10),
                            // Expanded(
                            //   child: Text("${mapItem["name"]} x${mapItem["qty"]}"),
                            // ),
                            // Text("Rs.${mapItem["price"]}"),
                          );
                        }).toList(),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// VIEW CART BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Nav.toAnimated(context, ConfirmOrderview(restaurantId: rest["restaurantId"],));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "View your cart",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
      
        },
      ),
   
   
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl:
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDfFs6cFxfqoOOsG26k8nCOm9D9KAMNtT1nA&s",
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
          Text(
            "Hungry?",
            style: AppText.titleLarge.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(
            "You haven't added anything to your cart!",
            style: AppText.bodyMedium.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Nav.to(context, BottomNavi());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Browse",
              style: AppText.titleLarge.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _customBottomSheet(
  CartViewModel cartVm,
  BuildContext context,
  String restaurantId, [
  String? itemId, // itemId optional
]) {
  return Material(
    color: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // DELETE ITEM (agar itemId hai)
          if (itemId != null)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(
                "Delete Item",
                style: AppText.bodyLarge.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                await cartVm.removeItem(itemId);
                Navigator.pop(context);
              },
            ),

          // DELETE RESTAURANT
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: Text(
              "Delete Restaurant",
              style: AppText.bodyLarge.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onTap: () async {
              await cartVm.removeRestaurant(restaurantId);
              Navigator.pop(context);
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
