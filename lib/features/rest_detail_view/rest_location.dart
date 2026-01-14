import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';

class RestaurantInfoScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantInfoScreen({super.key, required this.restaurant});

  @override
  State<RestaurantInfoScreen> createState() => _RestaurantInfoScreenState();
}

class _RestaurantInfoScreenState extends State<RestaurantInfoScreen> {
  bool showOpeningHours = false;

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final lat = restaurant.location['lat'] ?? 0.0;
    final lng = restaurant.location['lng'] ?? 0.0;
    final address = restaurant.location['address'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,


 appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child:Divider(thickness: 0.7,height: 0,color: Colors.grey.shade400,endIndent: 0,indent: 0,)
          ),
        titleSpacing: 0,
        title: Text(
          restaurant.name.toString(),
          style: AppText.bodyLarge.copyWith(color: Colors.black, fontSize: 20),
        ),
      ),
     
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// OPEN STATUS + VIEW MORE
            InkWell(
              onTap: () {
                setState(() {
                  showOpeningHours = !showOpeningHours;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Now open until 23:59",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      showOpeningHours ? "View less" : "View more",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: showOpeningHours ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),

            /// EXPANDABLE OPENING HOURS
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: showOpeningHours
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(),
              secondChild: const OpeningHoursContent(),
            ),

            /// ADDRESS
            _infoRow(
              icon: Icons.location_on_outlined,
              title: address,
            ),

            const SizedBox(height: 12),

            /// MAP
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("restaurant"),
                      position: LatLng(lat, lng),
                      infoWindow: InfoWindow(
                        title: restaurant.name,
                        // snippet: "Delivery Fee: Rs.${restaurant.deliveryFee.toStringAsFixed(0)}",
                      ),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DELIVERY FEE
            _section(
              title: "Delivery fee",
              subtitle: "Delivery is charged based on time of day, distance and surge conditions",
            ),

            /// MIN ORDER
            _section(
              title: "Minimum order",
              subtitle: "For orders below Rs. 149.00, small order fee applies",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// INFO ROW
  Widget _infoRow({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION
  Widget _section({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// OPENING HOURS CONTENT
class OpeningHoursContent extends StatelessWidget {
  const OpeningHoursContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Today", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          SizedBox(height: 6),
          Text("00:00 - 03:30"),
          Text("12:00 - 23:59"),
          SizedBox(height: 20),
          Divider(),
          Text("Weekly schedule", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          SizedBox(height: 16),
          Text("Monday", style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text("00:00 - 03:30"),
          Text("12:30 - 23:59"),
          SizedBox(height: 16),
          Text("Tuesday - Sunday", style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text("00:00 - 03:30"),
          Text("12:00 - 23:59"),
        ],
      ),
    );
  }
}
