import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    if (query.isEmpty) return [];
    query = query.toLowerCase();

    List<Map<String, dynamic>> matchedRestaurants = [];

    var restaurants = await _firestore.collection('restaurants').get();

    for (var restDoc in restaurants.docs) {
      String restId = restDoc.id;
      String name = (restDoc.data()['name'] ?? '').toString().toLowerCase();

      bool restaurantMatch = name.contains(query);
      bool itemMatch = false;

      var categories = await _firestore.collection('restaurants').doc(restId).collection('categories').get();

      for (var catDoc in categories.docs) {
        String catName = (catDoc.data()['name'] ?? '').toString().toLowerCase();
        if (catName.contains(query)) itemMatch = true;

        var items = await catDoc.reference.collection('items').get();
        for (var itemDoc in items.docs) {
          String itemName = (itemDoc.data()['name'] ?? '').toString().toLowerCase();
          if (itemName.contains(query)) itemMatch = true;
        }
      }

      if (restaurantMatch || itemMatch) {
        matchedRestaurants.add({
          "id": restId,
          "name": restDoc.data()['name'] ?? '',
          "image": restDoc.data()['image'] ?? '',
          "rating": (restDoc.data()['rating'] ?? 0).toDouble(),
          "deliveryTime": restDoc.data()['deliveryTime'] ?? '',
        });
      }
    }

    return matchedRestaurants;
  }
}
