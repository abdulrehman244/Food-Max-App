// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_delivery_app/data/models/user_model.dart';
import 'package:geolocator/geolocator.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// 🔵 GOOGLE SIGN‑IN
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print("GoogleSignInService: Starting Google Sign-In");

      await _googleSignIn.initialize();
      print("GoogleSignInService: GoogleSignIn initialized");

      final googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      print("GoogleSignInService: Google user: $googleUser");


      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: "ERROR_MISSING_ID_TOKEN",
          message: "Missing Google ID Token",
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      print("GoogleSignInService: Firebase user signed in: ${user?.uid}");

      bool isNewUser = false;

      if (user != null) {
        final userDocRef =
            FirebaseFirestore.instance.collection("users").doc(user.uid);
        final docSnap = await userDocRef.get();
        print("GoogleSignInService: User doc exists: ${docSnap.exists}");

        // ---------------- Handle New User ----------------
        if (!docSnap.exists) {
          Position position = await _getCurrentPosition();
          String address =
              await _getAddressFromLatLng(position.latitude, position.longitude);

          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? "",
            email: user.email ?? "",
            location: {
              "lat": position.latitude,
              "lng": position.longitude,
              "address": address,
            },
            favoriteRestaurants: [],
            cartItems: [],
          );

          await userDocRef.set(newUser.toMap());
          isNewUser = true;
        } else {
          // ---------------- Existing User ----------------
          Map<String, dynamic> updatedData = {
            "name": user.displayName ?? docSnap['name'] ?? "",
            "email": user.email ?? docSnap['email'] ?? "",
          };

          // Update location if missing
          if (docSnap['location'] == null || docSnap['location'].isEmpty) {
            Position position = await _getCurrentPosition();
            String address = await _getAddressFromLatLng(
                position.latitude, position.longitude);

            updatedData['location'] = {
              "lat": position.latitude,
              "lng": position.longitude,
              "address": address,
            };
          }

          await userDocRef.update(updatedData);
          print("GoogleSignInService: Existing user updated in Firestore");
        }
      }

      print(
          "GoogleSignInService: Sign-In completed. User: ${user?.uid}, isNewUser: $isNewUser");
      return {"user": user, "isNewUser": isNewUser};
    } catch (e) {
      print("GoogleSign‑In Error: $e");
      return {"user": null, "isNewUser": false};
    }
  }

  /// 🔴 LOGOUT
  static Future<void> signOut() async {
    print("GoogleSignInService: Signing out");
    await _auth.signOut();
    await _googleSignIn.signOut();
    print("GoogleSignInService: Sign out completed");
  }

  static User? getCurrentUser() {
    final user = _auth.currentUser;
    print("GoogleSignInService: Current user: ${user?.uid}");
    return user;
  }

  // ---------------- Location Helpers ----------------
  static Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high);
  }

  static Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
      return "Address not found";
    } catch (e) {
      print("Error in reverse geocoding: $e");
      return "Address error";
    }
  }
}

