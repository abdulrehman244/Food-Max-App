// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/routes/app_routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends ChangeNotifier {
  LatLng? selectedLocation;
  String selectedAddress = "";
  String currentCity = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  /// 🔹 Request permission and get current location
  Future<bool> checkAndRequestPermission(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackWithAction(
        context,
        "Location services are disabled. Please enable them.",
      );
      isLoading = false;
      notifyListeners();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack(context, "Location permission denied.");
        isLoading = false;
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackWithAction(
        context,
        "Location permissions are permanently denied. "
        "Please enable from settings.",
      );
      isLoading = false;
      notifyListeners();
      return false;
    }

    isLoading = false;
    notifyListeners();
    return true;
  }

  /// 🔹 Update location in ViewModel and save to Firestore
  Future<void> updateLocationAndSave({
    required LatLng latLng,
    required String address,
    required BuildContext context,
    required String currentCity,
    VoidCallback? onCompleted,
  }) async {
    isLoading = true;
    notifyListeners();

    selectedLocation = latLng;
    selectedAddress = address;
     this.currentCity = currentCity;

    await _saveToFirestore(context);

    isLoading = false;
    notifyListeners();

    onCompleted?.call(); // 🔥 VERY IMPORTANT

    // await saveLocationToFirestore(context);
  }

  Future<void> _saveToFirestore(BuildContext context) async {
    try {
      final uid = _auth.currentUser!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "location": {
          "lat": selectedLocation!.latitude,
          "lng": selectedLocation!.longitude,
          "address": selectedAddress,
          "city": currentCity,
        },
      });
    } catch (e) {
      _snack(context, "Failed to save location");
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 🔹 Firestore me location save karna
  Future<void> saveLocationToFirestore(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    if (selectedLocation == null) {
      _showSnack(context, "No location selected.");
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "location": {
          "lat": selectedLocation!.latitude,
          "lng": selectedLocation!.longitude,
          "address": selectedAddress,
          "city": currentCity,
        },
      });

      // 🔹 Navigate to Notification screen
      Navigator.pushReplacementNamed(context, AppRoutes.notificationAccess);

      isLoading = true;
      notifyListeners();
    } catch (e) {
      _showSnack(context, "Failed to save location.");
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSnackWithAction(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: "Open Settings",
          onPressed: () {
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }
}
