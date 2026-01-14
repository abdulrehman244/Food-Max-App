import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/restaurant_service.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';

class RestaurantViewModel extends ChangeNotifier {
  final RestaurantService _service = RestaurantService();

  final name = TextEditingController();
  final rating = TextEditingController();
  final deliveryFee = TextEditingController();
  final deliveryTime = TextEditingController();
  final type = TextEditingController();
  final imageUrl = TextEditingController();
  final logoUrl = TextEditingController();
  final location = TextEditingController();

   Map<String, dynamic> locationMap = {};

  bool isLoading = false;

  Future<void> saveRestaurant() async {
    if (name.text.isEmpty || imageUrl.text.isEmpty || type.text.isEmpty) return;

    isLoading = true;
    notifyListeners();

    final restaurant = RestaurantModel(
      id: '',
      name: name.text,
      rating: double.tryParse(rating.text) ?? 0,
      deliveryFee: double.tryParse(deliveryFee.text) ?? 0,
      deliveryTime: deliveryTime.text,
      type: type.text,
      image: imageUrl.text,
      logo: logoUrl.text,
      location: locationMap // yaha error araha hai
    );

    await _service.addRestaurant(restaurant);

    name.clear();
    rating.clear();
    deliveryFee.clear();
    deliveryTime.clear();
    type.clear();
    imageUrl.clear();
    logoUrl.clear();
    location.clear();

    isLoading = false;
    notifyListeners();
  }



Future<void> updateRestaurant(String restaurantId) async {
  final updatedData = {
    'name': name.text,
    'rating': double.tryParse(rating.text) ?? 0,
    'deliveryFee': double.tryParse(deliveryFee.text) ?? 0,
    'deliveryTime': deliveryTime.text,
    'type': type.text,
    'image': imageUrl.text,
    'logo': logoUrl.text,
    'location': locationMap, // yahan map bhej rahe ho
  };

  await _service.updateRestaurant(restaurantId, updatedData);
  notifyListeners();
}



  // ✅ Delete Restaurant
  Future<void> deleteRestaurant(String restaurantId) async {
    await _service.deleteRestaurant(restaurantId);
    notifyListeners();
  }

  Stream<List<RestaurantModel>> getRestaurants() {
    return _service.getRestaurants();
  }
}
