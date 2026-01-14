import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/localization/google_map.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/widgets/addressCard_widget.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/auth/location%20access/location_viewmodel.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class MylocationView extends StatelessWidget {
  const MylocationView({super.key});

  @override
  Widget build(BuildContext context) {
    // final model = context.watch<LocationViewModel>();
      final locationVM = context.watch<LocationViewModel>();

    LatLng location = const LatLng(0.0, 0.0);
    final homeVM = context.watch<HomeViewModel>();
    final lat = homeVM.currentUser?.location?['lat'] ?? 0.0;
    final lng = homeVM.currentUser?.location?['lng'] ?? 0.0;

    location = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Address",
          style: AppText.bodyLarge.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -6),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: MyButton(
            title: "Add new location",
             ontap: () async {
                  final granted = await locationVM
                      .checkAndRequestPermission(context);
                  if (!granted) return;

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  GoogleMapView(),
                    ),
                  );

                  if (result == null) return;

                  locationVM.updateLocationAndSave(
                    latLng: LatLng(
                      result['lat'],
                      result['lng'],
                    ),
                    address: result['address'],
                    currentCity: result['city'] ,
                    context: context,
                    onCompleted: () async {
                      // 🔥 REFRESH HOME DATA EVERYWHERE
                      await context
                          .read<HomeViewModel>()
                          .refreshUserLocation();

                     
                    },
                  );
                },
          ),
        ),
      ),
     
     
     
      body: locationVM.isLoading
            ?  Center(child: Lottie.asset("assets/lottie/loader.json",height: 100,width: 100))
            : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AddresscardWidget(homeVM: homeVM, title: 'Your location', location: location,),
            ],
        ),
      ),
    );
  }
}
