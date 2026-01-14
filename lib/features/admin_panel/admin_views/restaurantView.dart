import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/restaurant_view_model.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/core/widgets/custom_textFiled.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/config/localization/google_map.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';

class AddRestaurantView extends StatefulWidget {
  final String? restaurantId;
  final RestaurantModel? existingData;

  const AddRestaurantView({super.key, this.restaurantId, this.existingData});

  @override
  State<AddRestaurantView> createState() => _AddRestaurantViewState();
}

class _AddRestaurantViewState extends State<AddRestaurantView> {
  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final model = context.read<RestaurantViewModel>();
      model.name.text = widget.existingData!.name;
      model.rating.text = widget.existingData!.rating.toString();
      model.deliveryFee.text = widget.existingData!.deliveryFee.toString();
      model.deliveryTime.text = widget.existingData!.deliveryTime;
      model.type.text = widget.existingData!.type;
      model.imageUrl.text = widget.existingData!.image;
      model.logoUrl.text = widget.existingData?.logo ?? "";
      model.locationMap = widget.existingData!.location; // <-- existing map
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantViewModel>(
      builder: (context, model, _) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
                title: Text(widget.restaurantId != null
                    ? "Edit Restaurant"
                    : "Add Restaurant")),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image Container
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

                    CustomTextField(
                      controller: model.imageUrl,
                      labelText: "Restaurant Image URL",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          // ignore: invalid_use_of_visible_for_testing_member
                          if (model.imageUrl.text.isNotEmpty) model.notifyListeners();
                        },
                        child: const Icon(Icons.done, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),

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

                    CustomTextField(
                      controller: model.logoUrl,
                      labelText: "Logo Image URL (Optional)",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          // ignore: invalid_use_of_visible_for_testing_member
                          if (model.logoUrl.text.isNotEmpty) model.notifyListeners();
                        },
                        child: const Icon(Icons.done, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),

                    CustomTextField(controller: model.name, labelText: "Restaurant Name"),
                    const SizedBox(height: 10),
                    CustomTextField(controller: model.rating, labelText: "Rating"),
                    const SizedBox(height: 10),
                    CustomTextField(controller: model.deliveryFee, labelText: "Delivery Fee"),
                    const SizedBox(height: 10),
                    CustomTextField(controller: model.deliveryTime, labelText: "Delivery Time"),
                    const SizedBox(height: 10),
                    CustomTextField(controller: model.type, labelText: "Restaurant Type"),
                    const SizedBox(height: 20),

                    MyButton(
                      title: "Select Google Map Location",
                      ontap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GoogleMapView()),
                        );
                        if (result != null) {
                          model.locationMap = {
                            "address": result['address'],
                            "lat": result['lat'],
                            "lng": result['lng'],
                          };
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                  MyButton(
  title: model.isLoading ? "Saving..." : widget.restaurantId != null ? "Update Restaurant" : "Add Restaurant",
  ontap: () {
    if (!model.isLoading) {
      if (widget.restaurantId != null) {
        model.updateRestaurant(widget.restaurantId!); // ab error nahi aayega
      } else {
        model.saveRestaurant();
      }
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
