import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add restaurant
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    await _firestore.collection('restaurants').add(restaurant.toMap());
  }

  // Update restaurant
  Future<void> updateRestaurant(String restaurantId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('restaurants').doc(restaurantId).update(updatedData);
  }

  // Delete restaurant
  Future<void> deleteRestaurant(String restaurantId) async {
    await _firestore.collection('restaurants').doc(restaurantId).delete();
  }

  // Get restaurants as Stream
  Stream<List<RestaurantModel>> getRestaurants() {
  return FirebaseFirestore.instance.collection('restaurants')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList());
}


}
