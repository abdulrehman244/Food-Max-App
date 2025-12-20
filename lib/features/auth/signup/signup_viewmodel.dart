// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/auth_service.dart';
import 'package:food_delivery_app/core/services/user_service.dart';
import 'package:food_delivery_app/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = "";

  Future<bool> signUp() async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    print("SignupViewModel: Starting signup with email: $email");

    // --------------------------- VALIDATIONS ---------------------------
    if (name.isEmpty) {
      errorMessage = "Name cannot be empty";
      print("SignupViewModel Error: $errorMessage");
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (email.isEmpty) {
      errorMessage = "Email cannot be empty";
      print("SignupViewModel Error: $errorMessage");
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (!email.contains("@") || !email.contains(".")) {
      errorMessage = "Enter a valid email";
      print("SignupViewModel Error: $errorMessage");
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      errorMessage = "Password must be at least 6 characters";
      print("SignupViewModel Error: $errorMessage");
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      print("SignupViewModel: Calling AuthService.signUpWithEmail...");
      final user = await _authService.signUpWithEmail(email, password);

      print("SignupViewModel: Firebase user created: ${user?.uid}");

      if (user == null) {
        errorMessage = "Sign up failed. Please try again.";
        print("SignupViewModel Error: $errorMessage");
        isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = UserModel(uid: user.uid, name: name, email: email);
      print("SignupViewModel: Creating Firestore user: ${newUser.toMap()}");

      await _userService.createUser(newUser);

      isLoading = false;
      notifyListeners();
      print("SignupViewModel: Signup successful!");
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = "FirebaseAuthException: ${e.code} - ${e.message}";
      print("SignupViewModel Error: $errorMessage");
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = "Exception: $e";
      print("SignupViewModel Error: $errorMessage");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
