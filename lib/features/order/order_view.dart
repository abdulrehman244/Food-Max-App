import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:food_delivery_app/features/order/track_order.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final hive = HiveService();
    final homeVM = context.watch<HomeViewModel>();

    final uid = hive.isUserLoggedIn()
        ? hive.getUser()["uid"].toString()
        : "guest";

    final ordersBox = Hive.box(HiveService.ordersBoxName);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, animation, __) => BottomNavi(),
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 234, 244),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Nav.back(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: Text(
            "My Orders",
            style: AppText.titleLarge.copyWith(color: Colors.black, fontSize: 18),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: ordersBox.listenable(),
          builder: (context, box, _) {
            final List orders = List.from(
              box.get("orders_$uid", defaultValue: []),
            );

            if (orders.isEmpty) {
              return _emptyOrders();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final Map order = Map.from(orders[index] as Map);
                final List items = List.from(order["items"] ?? []);

                int totalItems = 0;
                double totalPrice = 0;

                for (var item in items) {
                  final int qty = int.tryParse(item["qty"].toString()) ?? 1;
                  final double price = double.tryParse(item["price"].toString()) ?? 0;
                  totalItems += qty;
                  totalPrice += qty * price;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: order["restaurantImage"]?.toString() ?? "",
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(width: 65, height: 65, color: Colors.grey),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 65,
                              height: 65,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order["restaurantName"]?.toString() ?? "Restaurant",
                                style: AppText.titleLarge.copyWith(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Your order is on the way 🚴",
                                style: TextStyle(color: Colors.green, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    "$totalItems items",
                                    style: AppText.bodyMedium.copyWith(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Rs. ${totalPrice.toStringAsFixed(0)}",
                                    style: AppText.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () {
                                  final userLat = homeVM.currentUser?.location?['lat'] ?? 0.0;
                                  final userLng = homeVM.currentUser?.location?['lng'] ?? 0.0;

                                  final restLat = parseLatLng(order["restaurantLat"], defaultValue: 24.8607);
                                  final restLng = parseLatLng(order["restaurantLng"], defaultValue: 67.0011);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrackOrderMapView(
                                        userLatLng: LatLng(userLat, userLng),
                                        restaurantLatLng: LatLng(restLat, restLng),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Track Order"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _emptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl:
                  "https://cdni.iconscout.com/illustration/premium/thumb/no-orders-yet-illustration-svg-download-png-13391224.png",
              width: 220,
              height: 220,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              "No order yet",
              style: AppText.titleLarge.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 6),
            Text(
              "Hungry? Place an order and it'll show here",
              textAlign: TextAlign.center,
              style: AppText.bodyMedium.copyWith(color: Colors.black, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// Utility to safely parse lat/lng
double parseLatLng(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  try {
    return double.parse(value.toString());
  } catch (e) {
    return defaultValue;
  }
}
