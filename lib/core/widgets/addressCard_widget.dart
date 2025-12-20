import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddresscardWidget extends StatefulWidget {

    final HomeViewModel homeVM;
  final String title;
  final LatLng location;
  final Widget? icon;
  const AddresscardWidget({
    super.key,
    required this.homeVM,
    required this.title,
    required this.location,
    this.icon,
  });


  @override
  State<AddresscardWidget> createState() => _AddresscardWidgetState();
}

class _AddresscardWidgetState extends State<AddresscardWidget> {
   GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant AddresscardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔥 LOCATION CHANGE DETECT
    if (oldWidget.location != widget.location) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(widget.location));
    }
  }

  @override
  Widget build(BuildContext context) {
    return   Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.place_outlined, size: 30),
                SizedBox(width: 5),
                Text(
                  widget.title,
                  style: AppText.titleLarge.copyWith(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Spacer(),
                widget.icon ?? SizedBox(),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 150,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: widget.location, // ya acces nhiho raha
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('loc'),
                      position: widget.location,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed, // black marker
                      ),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.homeVM.currentUser?.location?['address'] ?? "Loading....",
              style: AppText.bodyMedium.copyWith(color: Colors.black),
            ),
            SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }
}


