  // ignore_for_file: unnecessary_cast

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:food_delivery_app/data/models/restaurant_model.dart';

  class RestaurantService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Add restaurant
    Future<void> addRestaurant(RestaurantModel restaurant) async {
      await _firestore.collection('restaurants').add(restaurant.toMap());
    }

    // Get restaurants as Stream
    Stream<List<RestaurantModel>> getRestaurants() {
      return _firestore.collection('restaurants').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList(),
      );
    }
  }
