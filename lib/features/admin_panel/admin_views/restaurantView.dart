// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/restaurant_view_model.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/core/widgets/custom_textFiled.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/config/localization/google_map.dart';

class AddRestaurantView extends StatelessWidget {
  const AddRestaurantView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantViewModel>(
      builder: (context, model, _) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(title: const Text("Add Restaurant")),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Restaurant Image Container
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        image: model.imageUrl.text.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(model.imageUrl.text),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: model.imageUrl.text.isEmpty
                          ? const Center(child: Text("Restaurant Image URL"))
                          : null,
                    ),
                    const SizedBox(height: 10),

                    // Image URL Field
                    CustomTextField(
                      controller: model.imageUrl,
                      labelText: "Restaurant Image URL",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          if (model.imageUrl.text.isNotEmpty) {
                            // Update container preview
                            // ignore: invalid_use_of_protected_member
                            model.notifyListeners();
                          }
                        },
                        child: const Icon(Icons.done, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Logo Image Container
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        image: model.logoUrl.text.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(model.logoUrl.text),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: model.logoUrl.text.isEmpty
                          ? const Center(child: Text("Logo Image URL"))
                          : null,
                    ),
                    const SizedBox(height: 10),

                    // Logo URL Field
                    CustomTextField(
                      controller: model.logoUrl,
                      labelText: "Logo Image URL (Optional)",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          if (model.logoUrl.text.isNotEmpty) {
                            // Update logo preview
                            // ignore: invalid_use_of_protected_member
                            model.notifyListeners();
                          }
                        },
                        child: const Icon(Icons.done, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Restaurant Name
                    CustomTextField(
                      controller: model.name,
                      labelText: "Restaurant Name",
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: model.rating,
                      labelText: "Rating",
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: model.deliveryFee,
                      labelText: "Delivery Fee",
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: model.deliveryTime,
                      labelText: "Delivery Time",
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: model.type,
                      labelText: "Restaurant Type",
                    ),
                    const SizedBox(height: 20),

                    // Location Field
                    CustomTextField(
                      controller: model.location,
                      labelText: "Location Detail",
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      title: "Add Google Map Location",
                      ontap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GoogleMapView(),
                          ),
                        );
                        if (result != null) {
                          model.location.text =
                              "${result['address']} (Lat: ${result['lat']}, Lng: ${result['lng']})";
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Add Restaurant Button
                    MyButton(
                      title: model.isLoading ? "Saving..." : "Add Restaurant",
                      ontap: () {
                        if (!model.isLoading) {
                          model.saveRestaurant();
                        }
                      },
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
