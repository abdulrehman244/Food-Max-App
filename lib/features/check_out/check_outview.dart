import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/widgets/addressCard_widget.dart';
import 'package:food_delivery_app/core/widgets/buildTimeline_widget.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  LatLng location = const LatLng(0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    final homeVM = context.read<HomeViewModel>();

    final lat = homeVM.currentUser?.location?['lat'] ?? 0.0;
    final lng = homeVM.currentUser?.location?['lng'] ?? 0.0;

    location = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // 🔥 IMPORTANT
        scrolledUnderElevation: 0, // 🔥 IMPORTANT
        leading: Icon(Icons.close, color: Colors.black, size: 20),
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
          preferredSize: Size.fromHeight(40), // increased for title/subtitle
          child: buildTimeline(true),
        ),
      ),
      bottomNavigationBar: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
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
                  SizedBox(width: 5),
                  Text(
                    "(incl. fees and tax)",
                    style: AppText.bodyLarge.copyWith(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                  Spacer(),
                  Consumer<CartViewModel>(
                    builder: (context, cartVm, child) => Column(
                      children: [
                        cartVm.isSwitched
                            ? Text(
                                cartVm.finalTotal.toStringAsFixed(2),
                                style: AppText.bodyLarge.copyWith(
                                  color: Colors.pink,
                                  fontSize: 16,
                                ),
                              )
                            : Text(
                                cartVm.totalPrice.toStringAsFixed(2),
                                style: AppText.bodyLarge.copyWith(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),

                        cartVm.isSwitched
                            ? Text(
                                cartVm.totalPrice.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            Divider(color: Colors.grey.shade400, indent: 0, endIndent: 0),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MyButton(
                title: "Confirm payment and address",
                ontap: () async {

                },
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),

      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AddresscardWidget(homeVM: homeVM, title: 'Delivery address', location: location,icon: Icon(Icons.edit_outlined),),
                const SizedBox(height: 16),
                _deliveryOptions(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _step(String n, String text, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? Colors.black : Colors.grey,
          child: Text(n, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _deliveryOptions() {
    return Card(
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
          ],
        ),
      ),
    );
  }

  Widget _option(String title, String time, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Text(price),
        ],
      ),
    );
  }
}
