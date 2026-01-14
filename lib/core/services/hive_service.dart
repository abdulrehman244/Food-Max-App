import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:food_delivery_app/data/models/user_model.dart';

class HiveService {
  // BOX NAMES
  static const String userBoxName = 'userBox';
  static const String favBoxName = 'favoritesBox';
  static const String restaurantsBoxName = 'restaurantsBox';
  static const String recentSearchBoxName = 'recentSearchBox';
  static const String cartBoxName = 'cartBox';
  static const String appBoxName = 'appBox';
  static const String ordersBoxName = 'ordersBox';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String get _cartKey => 'cart_${_uid ?? "guest"}';
  String get _recentKey => 'recent_${_uid ?? "guest"}';

  // ===================== INIT HIVE =====================
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(userBoxName);
    await Hive.openBox(appBoxName);
    await Hive.openBox(ordersBoxName);
    await Hive.openBox(favBoxName);
    await Hive.openBox(cartBoxName);
    await Hive.openBox(restaurantsBoxName);
    await Hive.openBox(recentSearchBoxName);
  }

  // ===================== CART FUNCTIONS =====================

  List<Map<String, dynamic>> getUserOrders() {
    final uid = _uid ?? "guest";
    final box = Hive.box(ordersBoxName);
    final storedOrders = box.get("orders_$uid", defaultValue: []);

    if (storedOrders is List) {
      return storedOrders.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

/// ================= PLACE ORDER FOR RESTAURANT =================
Future<void> placeOrderForRestaurant({required String restaurantId}) async {
  final cartBox = Hive.box(HiveService.cartBoxName);
  final ordersBox = Hive.box(HiveService.ordersBoxName);
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

  // Get current cart
  final cartMap = cartBox.get('cart_$uid', defaultValue: {}) as Map;

  if (!cartMap.containsKey(restaurantId)) return;

  final restaurantOrder = Map<String, dynamic>.from(cartMap[restaurantId]);

  // Get existing orders
  final List existingOrders =
      List.from(ordersBox.get("orders_$uid", defaultValue: []));

  // Add new order with timestamp
  existingOrders.add({
    "restaurantId": restaurantOrder["restaurantId"],
    "restaurantName": restaurantOrder["restaurantName"],
    "restaurantImage": restaurantOrder["restaurantImage"],
    "restaurantLocation": restaurantOrder["restaurantLocation"],
    "items": restaurantOrder["items"],
    "orderTime": DateTime.now().toIso8601String(),
    "status": "Pending",
  });

  await ordersBox.put("orders_$uid", existingOrders);

  // Remove from cart
  cartMap.remove(restaurantId);
  await cartBox.put('cart_$uid', cartMap);
}

  Future<void> addToCart({
    required String restaurantId,
    required String restaurantName,
    required String restaurantImage,
    required Map<String, dynamic> restaurantLocation,
    required Map<String, dynamic> item,
  }) async {
    final box = Hive.box(cartBoxName);

    // Get current cart safely
    final storedCart = box.get(_cartKey, defaultValue: {});
    Map<String, dynamic> cart;
    if (storedCart is Map) {
      cart = Map<String, dynamic>.from(storedCart);
    } else {
      cart = {};
    }

    if (!cart.containsKey(restaurantId)) {
      cart[restaurantId] = {
        "restaurantId": restaurantId,
        "restaurantName": restaurantName,
        "restaurantImage": restaurantImage,
        "location": restaurantLocation, // ✅ FULL MAP SAVE
        "items": [],
      };
    }

    List items = [];
    final existingItems = cart[restaurantId]["items"];
    if (existingItems is List) items = List.from(existingItems);

    // Check if item exists
    final index = items.indexWhere((e) => e["itemId"] == item["itemId"]);
    if (index != -1) {
      items[index]["qty"] += item["qty"];
    } else {
      items.add(item);
    }

    cart[restaurantId]["items"] = items;
    await box.put(_cartKey, cart);
  }

Map<String, dynamic> getCart() {
  final box = Hive.box(cartBoxName);
  final storedCart = box.get(_cartKey, defaultValue: {});
  if (storedCart is Map) {
    try {
      return Map<String, dynamic>.from(storedCart);
    } catch (e) {
      debugPrint("HiveService getCart error: $e");
      return {};
    }
  }
  return {};
}

  // ===================== REMOVE SPECIFIC ITEM =====================
  Future<void> removeCartItem(String itemId) async {
    final box = Hive.box(cartBoxName);
    final storedCart = box.get(_cartKey, defaultValue: {});
    if (storedCart is! Map) return;

    final cart = Map<String, dynamic>.from(storedCart);
    final restaurantsToRemove = <String>[];

    cart.forEach((restaurantId, restData) {
      final rest = Map<String, dynamic>.from(restData);
      if (rest['items'] is List) {
        final items = (rest['items'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        items.removeWhere((item) => item['itemId'] == itemId);
        rest['items'] = items;
        if (items.isEmpty) {
          restaurantsToRemove.add(restaurantId);
        } else {
          cart[restaurantId] = rest;
        }
      }
    });

    // Remove restaurants with no items
    for (var restId in restaurantsToRemove) {
      cart.remove(restId);
    }

    await box.put(_cartKey, cart);
  }

  // ===================== REMOVE RESTAURANT =====================
  Future<void> removeRestaurant(String restaurantId) async {
    final box = Hive.box(cartBoxName);
    final storedCart = box.get(_cartKey, defaultValue: {});
    if (storedCart is! Map) return;

    final cart = Map<String, dynamic>.from(storedCart);
    cart.remove(restaurantId);

    await box.put(_cartKey, cart);
  }

  Future<void> clearCart() async {
    final box = Hive.box(cartBoxName);
    await box.delete(_cartKey);
  }

  // ===================== RECENT SEARCH =====================
  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final box = Hive.box(recentSearchBoxName);
    final storedList = box.get(_recentKey, defaultValue: []);
    final List<String> list = storedList is List
        ? List<String>.from(storedList)
        : [];

    list.remove(query);
    list.insert(0, query);
    if (list.length > 10) list.removeLast();

    await box.put(_recentKey, list);
  }

  List<String> getRecentSearches() {
    final box = Hive.box(recentSearchBoxName);
    final storedList = box.get(_recentKey, defaultValue: []);
    if (storedList is List) {
      return List<String>.from(storedList);
    }
    return [];
  }

  Future<void> clearRecentSearches() async {
    final box = Hive.box(recentSearchBoxName);
    await box.delete(_recentKey);
  }

  Future<void> removeRecentSearch(String query) async {
    final box = Hive.box(recentSearchBoxName);
    final storedList = box.get(_recentKey, defaultValue: []);
    final List<String> list = storedList is List
        ? List<String>.from(storedList)
        : [];
    list.remove(query);
    await box.put(_recentKey, list);
  }

  // ===================== RESTAURANTS =====================
  Future<void> saveRestaurants(List<Map<String, dynamic>> restaurants) async {
    final box = Hive.box(restaurantsBoxName);
    await box.put('allRestaurants', restaurants);
  }

  List<Map<String, dynamic>> getRestaurants() {
    final box = Hive.box(restaurantsBoxName);
    final storedData = box.get('allRestaurants', defaultValue: []);
    if (storedData is List) {
      return List<Map<String, dynamic>>.from(storedData);
    }
    return [];
  }

  Future<void> clearRestaurants() async {
    final box = Hive.box(restaurantsBoxName);
    await box.delete('allRestaurants');
  }

  // ===================== USER FUNCTIONS =====================
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
    final box = Hive.box(userBoxName);
    return box.get('uid') != null;
  }

  Future<void> logout() async {
    await Hive.box(userBoxName).clear();
    await Hive.box(favBoxName).clear();
    await Hive.box(cartBoxName).clear();
  }

  // ===================== FAVORITES =====================
  List<String> getFavorites() {
    final box = Hive.box(favBoxName);
    final storedList = box.get('favorites', defaultValue: []);
    if (storedList is List) {
      return List<String>.from(storedList);
    }
    return [];
  }

  Future<void> toggleFavorite(String restaurantId) async {
    final box = Hive.box(favBoxName);
    final favs = getFavorites();
    if (favs.contains(restaurantId)) {
      favs.remove(restaurantId);
    } else {
      favs.add(restaurantId);
    }
    await box.put('favorites', favs);
  }

  bool isFavorite(String restaurantId) {
    final favs = getFavorites();
    return favs.contains(restaurantId);
  }


  // ===================== APP / THEME =====================
Future<void> saveUserTheme(Color color) async {
  final box = Hive.box(HiveService.appBoxName);
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
  await box.put("theme_$uid", color.value); // Color ko int me save karenge
}

Color getUserTheme() {
  final box = Hive.box(HiveService.appBoxName);
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
  final storedValue = box.get("theme_$uid", defaultValue: Colors.pink.value);
  return Color(storedValue);
}

}
