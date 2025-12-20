// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/helpers/snackbar_helper.dart';
import 'package:food_delivery_app/core/services/auth_service.dart';
import 'package:food_delivery_app/core/services/google_signin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginViewmodel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = true;
  bool rememberMe = false;
  bool isLoading = false;

  void togglePassword() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  Future<void> loginUser(BuildContext context) async {
    if (emailController.text.trim().isEmpty) {
      SnackbarHelper.showError(context, "Please enter email");
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      SnackbarHelper.showError(context, "Please enter password");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      print("LOGIN VIEWMODEL: Trying login...");

      final user = await AuthService().signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      print("LOGIN VIEWMODEL: RESULT = $user");

      if (user != null) {
        print("LOGIN VIEWMODEL: Login success, loading profile...");

        await Provider.of<HomeViewModel>(
          context,
          listen: false,
        ).loadCurrentUser();
        emailController.clear();
        passwordController.clear();
        rememberMe = false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavi()),
        );
      } else {
        print("LOGIN VIEWMODEL: Returned NULL user");
        SnackbarHelper.showError(context, "Login failed");
      }
    } on FirebaseAuthException catch (e) {
      print("FIREBASE LOGIN ERROR: ${e.code} — ${e.message}");

      if (e.code == 'user-not-found') {
        SnackbarHelper.showError(context, "User doesn't exist");
      } else if (e.code == 'wrong-password') {
        SnackbarHelper.showError(context, "Invalid password");
      } else {
        SnackbarHelper.showError(context, e.message ?? "Login failed");
      }
    } catch (e, stack) {
      print("UNKNOWN LOGIN ERROR: $e");
      print("STACK TRACE: $stack");
      SnackbarHelper.showError(context, e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await GoogleSignInService.signInWithGoogle();

      isLoading = false;
      notifyListeners();

      return result; // {user, isNewUser}
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
