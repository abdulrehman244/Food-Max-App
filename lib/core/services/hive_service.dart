import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/data/models/user_model.dart';
import 'package:hive_ce_flutter/adapters.dart';

class HiveService {
  // BOX NAMES
  static const String userBoxName = 'userBox';
  static const String favBoxName = 'favoritesBox';
  static const String _boxName = 'cartBox';
  static const String restaurantsBoxName = 'restaurantsBox';

  Box get _box => Hive.box(_boxName);
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // INIT HIVE
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(userBoxName);
    await Hive.openBox(favBoxName);
    await Hive.openBox(restaurantsBoxName); // 🔥 new box
  }


//===================================================================
//=====================  Restaurant hive ===========================

// SAVE RESTAURANTS
  Future<void> saveRestaurants(List<Map<String, dynamic>> restaurants) async {
    final box = Hive.box(restaurantsBoxName);
    await box.put('allRestaurants', restaurants);
  }

  // GET RESTAURANTS
  List<Map<String, dynamic>> getRestaurants() {
    final box = Hive.box(restaurantsBoxName);
    final data = box.get('allRestaurants', defaultValue: []);
    return List<Map<String, dynamic>>.from(data);
  }

  // CLEAR RESTAURANTS
  Future<void> clearRestaurants() async {
    final box = Hive.box(restaurantsBoxName);
    await box.delete('allRestaurants');
  }



//====================================================================
  // --------------------------
  // USER FUNCTIONS
  // --------------------------
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box(userBoxName);
    await box.put('uid', user.uid);
    await box.put('name', user.name);
    await box.put('email', user.email);
    await box.put('location', user.location);
  }

  Map<String, dynamic> getUser() {
    final box = Hive.box(userBoxName);
    return {
      "uid": box.get('uid'),
      "name": box.get('name'),
      "email": box.get('email'),
      "location": box.get('location'),
    };
  }

  bool isUserLoggedIn() {
    return Hive.box(userBoxName).get('uid') != null;
  }

  Future<void> logout() async {
    await Hive.box(userBoxName).clear();
    // await Hive.box(cartBoxName).clear();
    await Hive.box(favBoxName).clear();
  }

  // --------------------------
  // CART FUNCTIONS
  // --------------------------

  List<Map<String, dynamic>> getCartItems() {
    if (_uid == null) return []; // user login nahi
    final data = _box.get(_uid);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  void addItemToCart({
    required String name,
    required String image,
    required double price,
    required int quantity,
  }) {
    if (_uid == null) return; // user login nahi
    final List<Map<String, dynamic>> cartItems = getCartItems();

    final index = cartItems.indexWhere((item) => item['name'] == name);

    if (index != -1) {
      cartItems[index]['quantity'] += quantity;
    } else {
      cartItems.add({
        'name': name,
        'image': image,
        'price': price,
        'quantity': quantity,
      });
    }

    _box.put(_uid, cartItems);
  }

  void removeItemFromCart(String name) {
    if (_uid == null) return; // user login nahi
    final List<Map<String, dynamic>> cartItems = getCartItems();
    cartItems.removeWhere((item) => item['name'] == name);
    _box.put(_uid, cartItems);
  }

  void updateItemQuantity(String name, int quantity) {
    if (_uid == null) return;
    final cartItems = getCartItems();
    final index = cartItems.indexWhere((item) => item['name'] == name);
    if (index != -1) {
      cartItems[index]['quantity'] = quantity;
      _box.put(_uid, cartItems); // Hive me update
    }
  }

  void clearCartOnLogout() {
    if (_uid == null) return;
    _box.delete(_uid);
  }

  // --------------------------
  // FAVORITES FUNCTIONS
  // --------------------------
  List getFavorites() {
    return Hive.box(favBoxName).get('favorites', defaultValue: []);
  }

  Future<void> toggleFavorite(String restaurantId) async {
    final box = Hive.box(favBoxName);
    final favs = List<String>.from(box.get('favorites', defaultValue: []));
    if (favs.contains(restaurantId)) {
      favs.remove(restaurantId);
    } else {
      favs.add(restaurantId);
    }
    await box.put('favorites', favs);
  }

  bool isFavorite(String restaurantId) {
    final favs = Hive.box(favBoxName).get('favorites', defaultValue: []);
    return favs.contains(restaurantId);
  }
}
