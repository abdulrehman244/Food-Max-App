// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/localization/google_map.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'location_viewmodel.dart';

class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewModel>(
      builder: (context, model, _) {
        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/lottie/map.json"),
                  const SizedBox(height: 20),
                 model.isLoading ? Lottie.asset("assets/lottie/loader.json",height: 70,width: 70) : MyButton(
                    title: "Access LOCATION",
                    ontap: () async {
                      // 🔹 Step 1: Check & request permission
                      bool granted =
                          await model.checkAndRequestPermission(context);
          
                      if (!granted) return;
          
                      // 🔹 Step 2: Navigate to GoogleMapView
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GoogleMapView(),
                        ),
                      );
          
                      // 🔹 Step 3: If user selected a location, save it
                      if (result != null &&
                          result is Map<String, dynamic> &&
                          result['lat'] != null &&
                          result['lng'] != null &&
                          result['city'] != null &&
                          result['address'] != null
                          ) {
                        final lat = result['lat'] as double;
                        final lng = result['lng'] as double;
                        final address = result['address'] as String;
                        final currentCity = result['city'] as String;



                        model.updateLocationAndSave(
                          latLng: LatLng(lat, lng), 
                          address: address,
                           currentCity: currentCity,
                          context: context,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "DFOOD WILL ACCESS YOUR LOCATION\nONLY WHILE USING THE APP",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}



