import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/features/admin_panel/admin_views/admin_panel.dart';
import 'package:food_delivery_app/features/auth/location%20access/location_view.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/config/theme/app_color.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/features/auth/login/login_viewmodel.dart';
import 'package:food_delivery_app/features/auth/signup/signup_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewmodel>(
      builder: (context, vm, child) {
        return Container(
          color: const Color(0xFF0E0E23),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFF0E0E23),
              body: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Login",
                        style: AppText.titleLarge.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Please sign in to your existing account",
                        style: AppText.bodyMedium.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 60),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 40,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // EMAIL
                                  Text(
                                    "EMAIL",
                                    style: AppText.bodyMedium.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: vm.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Email cannot be empty";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Gmail",
                                      filled: true,
                                      fillColor: const Color(0xFFF3F5F9),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.appColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  // PASSWORD
                                  Text(
                                    "PASSWORD",
                                    style: AppText.bodyMedium.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: vm.passwordController,
                                    obscureText: vm.isPasswordVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Password cannot be empty";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          vm.isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: vm.togglePassword,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF3F5F9),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.appColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: vm.rememberMe,
                                            onChanged: vm.toggleRememberMe,
                                          ),
                                          const Text("Remember me"),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          "Forgot Password",
                                          style: TextStyle(
                                            color: AppColors.appColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.appColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: vm.isLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();

                                                if (vm.emailController.text ==
                                                        "adminrehman@gmail.com" &&
                                                    vm
                                                            .passwordController
                                                            .text ==
                                                        "9999999") {
                                                  Nav.to(
                                                    context,
                                                    AdminPanelView(),
                                                  );
                                                }else{
                                                vm.loginUser(context);
                                                }

                                              }
                                            },
                                      child: vm.isLoading
                                          ? Lottie.asset(
                                              "assets/lottie/loader.json",
                                              height: 50,
                                              width: 50,
                                            )
                                          : Text(
                                              "LOG IN",
                                              style: AppText.bodyMedium
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // SIGN UP LINK
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don’t have an account?",
                                        style: AppText.bodyMedium.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignupView(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "SIGN UP",
                                          style: AppText.bodyLarge.copyWith(
                                            color: AppColors.appColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Center(
                                    child: Text(
                                      "Or",
                                      style: AppText.bodyMedium.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  // GOOGLE LOGIN BUTTON
                                  SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: vm.isLoading
                                          ? null
                                          : () async {
                                              try {
                                                final result = await vm
                                                    .signInWithGoogle();
                                                final user = result["user"];
                                                final isNewUser =
                                                    result["isNewUser"];

                                                if (!context.mounted) return;

                                                if (user != null) {
                                                  if (isNewUser) {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            LocationView(),
                                                      ),
                                                    );
                                                  } else {
                                                    await Provider.of<
                                                          HomeViewModel
                                                        >(
                                                          context,
                                                          listen: false,
                                                        )
                                                        .loadCurrentUser();
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            BottomNavi(),
                                                      ),
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Google Sign-In Failed",
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            "assets/png_images/google.png",
                                            height: 40,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Continue with Google",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
