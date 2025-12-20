import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_color.dart';
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
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartViewModel>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartViewModel, HomeViewModel>(
      builder: (context, cartVm, homeVm, child) {
        return Scaffold(
          backgroundColor: Colors.white,

          // ================= APP BAR =================
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

          // ================= BODY =================
          body: Stack(
            children: [
              cartVm.cartItems.isEmpty
                  ? _emptyCart(context)
                  : ListView.builder(
                      itemCount: cartVm.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartVm.cartItems[index];

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 20,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // <-- yahan border radius set
                              child: CachedNetworkImage(
                                imageUrl: item['image'] ?? "",
                                height: 70,
                                width: 60,
                                fit: BoxFit
                                    .cover, // <-- image container ke size ke hisaab se cover karegi
                                placeholder: (context, url) => Center(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    period: Duration(milliseconds: 1000),
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ), // <-- placeholder bhi rounded
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
                            ),
                            title: Text(
                              item['name'] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // ===== 3 DOTS ICON =====
                            trailing: IconButton(
                              icon: const Icon(Icons.more_horiz, size: 30),
                              onPressed: () => cartVm.openSheet(item),
                            ),
                          ),
                        );
                      },
                    ),

              // ===== BACKGROUND DIM =====
              if (cartVm.showSheet)
                GestureDetector(
                  onTap: () => cartVm.closeSheet(),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),

              // ===== BOTTOM SHEET =====
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                bottom: cartVm.showSheet ? 0 : -280,
                child: _customBottomSheet(cartVm),
              ),
            ],
          ),

          // ================= BOTTOM BAR =================
          bottomNavigationBar: cartVm.cartItems.isNotEmpty && !cartVm.showSheet
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {
                          Nav.to(context, ConfirmOrderview());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "View your cart",
                          style: AppText.bodyLarge.copyWith(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  // ================= BOTTOM SHEET UI =================
  Widget _customBottomSheet(CartViewModel cartVm) {
    if (cartVm.selectedItem == null) return const SizedBox();
    final item = cartVm.selectedItem!;

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
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(
                "Delete Item",
                style: AppText.bodyLarge.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              onTap: () => cartVm.removeFromCart(item['name']),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => cartVm.closeSheet(),
                  child: const Text("Close"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY CART =================
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
              final model = Provider.of<HomeViewModel>(context, listen: false);
              model.isSearchBarSticky = false;
              Nav.to(context, BottomNavi());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appColor,
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
