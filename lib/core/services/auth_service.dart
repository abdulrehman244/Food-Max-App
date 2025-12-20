// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmail(String email, String password,) async {
    try {
      print("AuthService: Signing up with email $email");
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      print("AuthService: Firebase user created: ${user?.uid}");

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "email": email,
          "name": "",
          "location": "",
          "fcmToken": "",
          "notificationsEnabled": true,
        });
        print("AuthService: User added to Firestore");
      }

      return user;
    } catch (e) {
      print("AuthService Sign Up Error: $e");
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      print("AuthService: Signing in with email $email");
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("AuthService: Sign in success: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      print("AuthService Sign In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      print("AuthService: Signing out");
      await _auth.signOut();
    } catch (e) {
      print("AuthService SignOut Error: $e");
    }
  }
}
