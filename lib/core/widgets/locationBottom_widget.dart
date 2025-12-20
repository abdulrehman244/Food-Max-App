import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:food_delivery_app/features/my_location/mylocation_view.dart';
import 'package:food_delivery_app/features/settings/theme_viewmodel.dart';
import 'package:provider/provider.dart';

class LocationConfirmBottomSheet extends StatelessWidget {
  const LocationConfirmBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final vm = context.watch<ThemeViewModel>();

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.50,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 🔘 DRAG HANDLE
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 TITLE
              Text(
                "Can you confirm if this is your location?",
                style: AppText.titleLarge.copyWith(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              // 🌍 COUNTRY ROW
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: [
                    const Icon(Icons.public, size: 25),
                    const SizedBox(width: 10),
                    const Text(
                      "🇵🇰 Pakistan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Divider(),
              ),

              // 📍 USE CURRENT LOCATION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.near_me_outlined,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Use my current location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Nav.to(context, MylocationView());
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 📍 SELECTED LOCATION CARD
              GestureDetector(
                onTap: () {
                  vm.toggle();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: vm.isSelected ? Colors.grey.shade200 : Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homeVm.userAddress,
                            style: AppText.titleLarge.copyWith(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            homeVm.userCity,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // const SizedBox(height: 10),

              // ➕ SELECT DIFFERENT LOCATION
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add),
                title: Text(
                  "Select a different location",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                    Nav.to(context, MylocationView());
                },
              ),

              // const Spacer(),
              SizedBox(height: 20),

              // 🔥 CONFIRM BUTTON
              MyButton(
                title: "Confirm your location",
                ontap: () {
                  Nav.back(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
