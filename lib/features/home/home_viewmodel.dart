// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/auth_service.dart';
import 'package:food_delivery_app/core/services/google_signin_service.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';
import 'package:food_delivery_app/core/services/user_service.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';
import 'package:food_delivery_app/data/models/user_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive_ce/hive.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final HiveService _hiveService = HiveService();

  final ScrollController scroll = ScrollController();
  bool isSearchBarSticky = false;
  int current = 0;
  String userCity = "";
  List<RestaurantModel> restaurants = [];
  bool isUserLoading = false;
  bool isRestaurantLoading = false;
  UserModel? currentUser;
  String userAddress = "";
  final UserService _userService = UserService();
  bool restaurantsFetched = false;
  bool isLoadingMore = false;
  List<String> favoriteIds = [];

  List<RestaurantModel> randomPopular = [];
  List<RestaurantModel> randomDiscount = [];
  List<RestaurantModel> randomNew = [];

  /// 🔥 FAVORITES (single source of truth)

  // ================= USER =================

  Future<void> loadCurrentUser() async {
    try {
      if (currentUser != null) return;

      isUserLoading = true;

      final data = await _userService.loadCurrentUser();
      if (data == null) {
        isUserLoading = false;
        return;
      }

      final location = data['location'] ?? {};
      final String city = location['city'] ?? "";
      final lat = double.tryParse(location['lat']?.toString() ?? '0') ?? 0.0;
      final lng = double.tryParse(location['lng']?.toString() ?? '0') ?? 0.0;

      currentUser = UserModel(
        uid: data['uid'],
        name: data['name'],
        email: data['email'],
        location: {
          "address": location['address'] ?? "Unknown",
          "lat": lat,
          "lng": lng,
          "city": city, // ✅ ADD
        },
        favoriteRestaurants: List<String>.from(
          data['favoriteRestaurants'] ?? [],
        ),
        cartItems: List<Map<String, dynamic>>.from(data['cartItems'] ?? []),
      );

      // SAVE USER TO HIVE
      await _hiveService.saveUser(currentUser!);

      /// ✅ SYNC FAVORITES ON LOGIN
      favoriteIds = List<String>.from(data['favoriteRestaurants'] ?? []);

      // SAVE TO HIVE
      final box = Hive.box(HiveService.favBoxName);
      await box.put('favorites', favoriteIds);

      userAddress = location['address'] ?? "Unknown";
      userCity = city;

      if (lat != 0 && lng != 0) {
        Future.microtask(() async {
          final address = await _getFullAddressFromLatLng(lat, lng);
          if (address.isNotEmpty) {
            userAddress = address;
            notifyListeners();
          }
        });
      }

      isUserLoading = false;
      notifyListeners();
    } catch (e) {
      isUserLoading = false;
      print(e);
    }
  }

  void _loadUserFromHive() {
    final user = _hiveService.getUser();

    if (user['uid'] != null) {
      final locationMap = user['location'] as Map? ?? {}; // ✅ cast to Map

      currentUser = UserModel(
        uid: user['uid'],
        name: user['name'],
        email: user['email'],
        location: Map<String, dynamic>.from(locationMap), // ensure type
        favoriteRestaurants: [], // optional
        cartItems: [], // optional
      );

      // ✅ Set address safely
      userAddress = locationMap['address']?.toString() ?? "";
      userCity = locationMap['city']?.toString() ?? "";
    }
  }

  // ================= FAVORITES =================

  void loadFavoritesFromHive() {
    final favs = Hive.box(
      HiveService.favBoxName,
    ).get('favorites', defaultValue: []);

    favoriteIds = List<String>.from(favs);
    notifyListeners();
  }

  bool isFavorite(String restaurantId) {
    return favoriteIds.contains(restaurantId);
  }

  /// ✅ PERFECT SYNC TOGGLE
  Future<void> toggleFavorite(String restaurantId) async {
    final box = Hive.box(HiveService.favBoxName);
    List<String> favs = List<String>.from(
      box.get('favorites', defaultValue: []),
    );

    if (favs.contains(restaurantId)) {
      favs.remove(restaurantId);
      await _userService.removeFavorite(restaurantId); // Firestore
    } else {
      favs.add(restaurantId);
      await _userService.addFavorite(restaurantId); // Firestore
    }

    // SAVE TO HIVE
    await box.put('favorites', favs);

    // UPDATE MEMORY
    favoriteIds = favs;

    notifyListeners();
  }

  //============================================================

  //================== Search Hive code ========================

  Future<void> searchFetchRestaurants({bool forceRefresh = false}) async {
  if (restaurantsFetched && !forceRefresh) {
    // 🔥 load from Hive first
    final localData = _hiveService.getRestaurants();
    if (localData.isNotEmpty) {
      restaurants = localData.map((e) => RestaurantModel.fromMap(e, e['id'])).toList();
      notifyListeners();
      return;
    }
  }

  isRestaurantLoading = true;
  notifyListeners();

  try {
    final snapshot = await _db.collection("restaurants").limit(50).get();
    restaurants = snapshot.docs
        .map((doc) {
          final map = doc.data();
          map['id'] = doc.id; // save docId
          return RestaurantModel.fromMap(map, doc.id);
        })
        .toList();

    // 🔥 Save to Hive for fast search later
    final listToSave = restaurants.map((r) => r.toMap()).toList();
    await _hiveService.saveRestaurants(listToSave);

    restaurantsFetched = true;
    notifyListeners();
  } catch (e) {
    print("Error fetching restaurants: $e");
  }

  isRestaurantLoading = false;
  notifyListeners();
}

// 🔥 FAST SEARCH USING HIVE
List<RestaurantModel> searchRestaurants(String query) {
  final all = _hiveService.getRestaurants();
  final filtered = all.where((r) {
    final name = r['name']?.toString().toLowerCase() ?? '';
    return name.contains(query.toLowerCase());
  }).toList();

  return filtered.map((e) => RestaurantModel.fromMap(e, e['id'])).toList();
}




  //============================================================

  // ================= Restaurant with logos ===================
  List<RestaurantModel> get restaurantsWithLogo {
    return restaurants
        .where((r) => r.logo != null && r.logo!.trim().isNotEmpty)
        .toList();
  }

  // ================= LOCATION =================

  Future<String> _getFullAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        userAddress = placemarks.first.street ?? "";
        userCity = placemarks.first.locality ?? "";
        notifyListeners();
        return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print("Error reverse geocoding: $e");
    }
    return "";
  }

  // ================= UI HELPERS =================

  final items = [
    {"image": "assets/png_images/discount.png", "title": "Offers"},
    {"image": "assets/png_images/basket.png", "title": "Mart"},
    {"image": "assets/png_images/food.png", "title": "New restaurants"},
    {"image": "assets/png_images/chef-hat.png", "title": "Homechef"},
    {"image": "assets/png_images/deal.png", "title": "Deals"},
    {"image": "assets/png_images/delivery-bike.png", "title": "Fast Delivery"},
  ];

  final List<String> images = [
    "https://cdn.pixabay.com/photo/2018/07/14/21/30/club-sandwich-3538455_1280.jpg",
    "https://cdn.pixabay.com/photo/2020/10/05/21/30/hamburger-5630800_1280.jpg",
    "https://cdn.pixabay.com/photo/2022/07/15/18/12/cheese-burger-7323672_1280.jpg"
  ];

  final List<Map<String, dynamic>> categoryTitles = [
    {
      "title": "Pizza",
      "image":
          "https://www.allrecipes.com/thmb/fFW1o307WSqFFYQ3-QXYVpnFj6E=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/48727-Mikes-homemade-pizza-DDMFS-beauty-4x3-BG-2974-a7a9842c14e34ca699f3b7d7143256cf.jpg",
    },
    {
      "title": "Burger",
      "image":
          "https://assets.epicurious.com/photos/5c745a108918ee7ab68daf79/1:1/w_2503,h_2503,c_limit/Smashburger-recipe-120219.jpg",
    },
    {
      "title": "Biryani",
      "image":
          "https://www.maggiarabia.com/sites/default/files/styles/srh_recipes/public/srh_recipes/30c29da8aec1403f42e82552d927abab.png?h=4f5b30f1&itok=7l1fu_HB",
    },
    {
      "title": "Pasta",
      "image":
          "https://www.yummytummyaarthi.com/wp-content/uploads/2022/11/red-sauce-pasta-1-500x500.jpg",
    },
    {
      "title": "Ice Cream",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQN_qnZySSopHYG9PIqtCTsKximDTTh4l2DRA&s",
    },
    {
      "title": "Chowmein",
      "image":
          "https://i.ytimg.com/vi/gbygXUDbf2Q/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCCbRvjuTJjSuiR5OSYJuE9AKfsDg",
    },
    {
      "title": "Rice",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbbHMLbVwAUDT7B-oqUxYbrZguIHbIckk3yQ&s",
    },
  ];

  HomeViewModel() {
    _loadUserFromHive();
    loadFavoritesFromHive();
    scroll.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scroll.offset > 160 && !isSearchBarSticky) {
      isSearchBarSticky = true;
      notifyListeners();
    } else if (scroll.offset <= 160 && isSearchBarSticky) {
      isSearchBarSticky = false;
      notifyListeners();
    }

    if (scroll.position.pixels >= scroll.position.maxScrollExtent - 100) {
      if (!isLoadingMore) loadMoreRestaurants();
    }
  }

  void setCurrentIndex(int index) {
    current = index;
    notifyListeners();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  // inside HomeViewModel

  Future<void> refreshUserLocation() async {
    currentUser = null; // force reload
    userAddress = "";
    notifyListeners();

    await loadCurrentUser(); // firestore + hive
  }

  // ================= RESTAURANTS =================

  Future<void> fetchRestaurants() async {
    if (restaurantsFetched) return;
    restaurantsFetched = true;

    isRestaurantLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection("restaurants").limit(30).get();

      restaurants = snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();
      final copy = List<RestaurantModel>.from(restaurants)..shuffle();

      randomPopular = copy.take(10).toList();
      randomDiscount = copy.skip(10).take(10).toList();
      randomNew = copy.skip(20).take(10).toList();
    } catch (e) {
      print(e);
    }

    isRestaurantLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreRestaurants() async {
    if (restaurants.isEmpty) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final lastDoc = await _db
          .collection("restaurants")
          .doc(restaurants.last.id)
          .get();

      final snapshot = await _db
          .collection("restaurants")
          .startAfterDocument(lastDoc)
          .limit(10)
          .get();

      final moreRestaurants = snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();

      restaurants.addAll(moreRestaurants);
    } catch (e) {
      print(e);
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    restaurantsFetched = false;
    restaurants.clear();
    notifyListeners();

    await fetchRestaurants();
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final providers = user.providerData.map((e) => e.providerId).toList();

    //  final uid = user.uid;

    if (providers.contains('google.com')) {
      await GoogleSignInService.signOut();
    } else {
      await AuthService().signOut();
    }

    // inside HomeViewModel

    // 🔥 CLEAR USER SPECIFIC DATA
    // await _hiveService.clearCart(uid);
    await _hiveService.logout();

    clearUserData(); // 👈 reuse

    isSearchBarSticky = false;
    notifyListeners();
  }

  void clearUserData() {
    currentUser = null;
    userAddress = "";
    favoriteIds.clear();
    restaurants.clear();
    randomPopular.clear();
    randomDiscount.clear();
    randomNew.clear();
    restaurantsFetched = false;
    notifyListeners();
  }
}
