import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/services/notification_service.dart';
import 'package:food_delivery_app/core/widgets/addressCard_widget.dart';
import 'package:food_delivery_app/core/widgets/buildTimeline_widget.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/check_out/successfully.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final String restaurantId;

  const CheckoutScreen({super.key, required this.restaurantId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  LatLng location = const LatLng(0.0, 0.0);
  String _selectedDeliveryOption = '';

  @override
  Widget build(BuildContext context) {
    final homeVM = context.read<HomeViewModel>();
    final cartVm = context.watch<CartViewModel>();

    final lat = homeVM.currentUser?.location?['lat'] ?? 0.0;
    final lng = homeVM.currentUser?.location?['lng'] ?? 0.0;
    location = LatLng(lat, lng);

    final restaurant = cartVm.cart.firstWhere(
      (r) => r["restaurantId"] == widget.restaurantId,
      orElse: () => {},
    );

    if (restaurant.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Cart is empty", style: TextStyle(fontSize: 16)),
        ),
      );
    }

    final List items = restaurant["items"];
    double subTotal = 0;
    for (var item in items) {
      final price = (item["price"] as num).toDouble();
      final qty = (item["qty"] as num).toInt();
      subTotal += price * qty;
    }

    double deliveryFee = cartVm.isSwitched ? 150 : 0;
    double total = subTotal + deliveryFee;

    

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: const Icon(Icons.close, color: Colors.black, size: 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cart',
              style: AppText.bodyLarge.copyWith(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: buildTimeline(true),
        ),
      ),
      bottomNavigationBar: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Total",
                    style: AppText.titleLarge.copyWith(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "(incl. fees and tax)",
                    style: AppText.bodyLarge.copyWith(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  cartVm.isSwitched
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Rs. ${subTotal - 430}",
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Rs. ${subTotal + 150}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Rs. ${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.grey, indent: 0, endIndent: 0),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MyButton(
                title: "Confirm address",
                ontap: () async {

                   final cartVm = context.read<CartViewModel>();



                  final restaurant = cartVm.cart.firstWhere(
                    (r) => r["restaurantId"] == widget.restaurantId,
                    orElse: () => {},
                  );

                  if (restaurant.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cart is empty")),
                    );
                    return;
                  }

                  // Show notification for each item
                  await NotificationService.showEachItemNotification(
                    restaurantName: restaurant["restaurantName"],
                    items: restaurant["items"],
                  );

                  // Navigate to home
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 400,
                      ),
                      pageBuilder: (_, animation, __) => Successfully(),
                      transitionsBuilder:
                          (_, animation, secondaryAnimation, child) {
                            final offsetAnimation =
                                Tween<Offset>(
                                  begin: const Offset(
                                    1.0,
                                    0.0,
                                  ), // 👉 Right se slide
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                    reverseCurve: Curves.easeInCubic,
                                  ),
                                );

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                    ),
                    (route) => false,
                  );

      // Place order for this restaurant
      await cartVm.placeOrder(widget.restaurantId);
                },
              ),
            ),
          
          
          
          
          
          
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AddresscardWidget(
                  homeVM: homeVM,
                  title: 'Delivery address',
                  location: location,
                  icon: const Icon(Icons.edit_outlined),
                ),
                const SizedBox(height: 16),
                _deliveryOptions(),
                const SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 4), // x, y
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "💳 Payment method",
                        style: AppText.titleLarge.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "+ Add a payment method",
                        style: AppText.bodyMedium.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryOptions() {
    return Card(
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _option('Priority', '10 - 25 mins', '+ Rs. 70.00'),
            const SizedBox(height: 8),
            _option('Saver', '25 - 40 mins', '- Rs. 24.75'),
            const SizedBox(height: 8),
            _option('Stardard', '', "5- 20 mins"),
          ],
        ),
      ),
    );
  }

  Widget _option(String title, String time, String price) {
    final bool isSelected = _selectedDeliveryOption == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryOption = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.grey.shade100 : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (time.isNotEmpty)
                  Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            if (price.isNotEmpty)
              Text(price, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
