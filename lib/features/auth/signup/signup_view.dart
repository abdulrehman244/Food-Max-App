// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/helpers/snackbar_helper.dart';
import 'package:food_delivery_app/features/auth/location%20access/location_view.dart';
import 'package:food_delivery_app/features/auth/signup/signup_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // ← Added

    return Consumer<SignupViewModel>(
      builder: (context, vm, child) {
        return Container(
          color: const Color(0xFF0E0E23),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFF0E0E23),
              body: Form(
                key: formKey, // ← Added
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            "assets/svg_images/Back.svg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Sign Up",
                      style: AppText.titleLarge.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please sign up to get started",
                      style: AppText.bodyMedium.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 50),
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
                                Text(
                                  "NAME",
                                  style: AppText.bodyMedium.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: vm.nameController,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    hintText: "Enter Your Name",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF3F5F9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:  BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),

                                  // VALIDATION
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Name is required";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  "EMAIL",
                                  style: AppText.bodyMedium.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: vm.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: "Enter your Gmail",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF3F5F9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:  BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),

                                  // VALIDATION
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Email is required";
                                    }
                                    if (!value.contains("@") ||
                                        !value.contains(".")) {
                                      return "Enter correct email please";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  "PASSWORD",
                                  style: AppText.bodyMedium.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: vm.passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF3F5F9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:  BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),

                                  // VALIDATION
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Password is required";
                                    }
                                    if (value.length < 6) {
                                      return "Password must be greater than 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: vm.isLoading
                                      ? Lottie.asset(
                                          "assets/lottie/loader.json",
                                          height: 80,
                                          width: 80,
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          // OnPressed example
                                          onPressed: () async {
                                            print(
                                              "SignupView: Sign Up button pressed",
                                            );
                                            if (!formKey.currentState!
                                                .validate()) {
                                              print(
                                                "SignupView: Form validation failed",
                                              );
                                              return;
                                            }

                                            FocusScope.of(context).unfocus();

                                            print(
                                              "SignupView: Calling ViewModel.signUp()",
                                            );
                                            bool success = await vm.signUp();

                                            if (success) {
                                              print(
                                                "SignupView: Signup successful, navigating...",
                                              );

                                              vm.emailController.clear();
                                              vm.nameController.clear();
                                              vm.passwordController.clear();
                                              Nav.toAnimatedReplacement(
                                                context,
                                                LocationView(),
                                              );

                                              // Navigator.pushReplacementNamed(
                                              //   context,
                                              //   AppRoutes.locationAccess,
                                              // );
                                            } else {
                                              print(
                                                "SignupView: Signup failed with error: ${vm.errorMessage}",
                                              );
                                              SnackbarHelper.showError(
                                                context,
                                                vm.errorMessage,
                                              );
                                            }
                                          },

                                          child: Text(
                                            "SIGN UP",
                                            style: AppText.bodyMedium.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
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
        );
      },
    );
  }
}
