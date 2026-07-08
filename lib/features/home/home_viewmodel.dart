// ignore_for_file: avoid_print
import 'dart:async';

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

  bool promoVisible = false;
  bool promoDismissed = false;

  // bool bottomVisible = false;
  // bool bottomDismissed = false;

  final ValueNotifier<bool> stickySearch = ValueNotifier(false);
  int current = 0;
  String selectedCategory = "";
  String selectedItem = "";
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
  ///

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

void toggleFavorite(String restaurantId) async {
  final box = Hive.box(HiveService.favBoxName);

  List<String> favs =
      List<String>.from(box.get('favorites', defaultValue: []));

  if (favs.contains(restaurantId)) {
    favs.remove(restaurantId); // ❌ UN-FAV
  } else {
    favs.add(restaurantId);    // ✅ FAV
  }

  await box.put('favorites', favs);

  favoriteIds = favs;
  notifyListeners();
}


bool favSyncLoading = false;

Future<void> syncFavoritesWithFirestore() async {
  if (currentUser == null) return;

  favSyncLoading = true;
  notifyListeners();

  final uid = currentUser!.uid;

  // 1️⃣ HIVE → GET
  final hiveFavs = List<String>.from(
    Hive.box(HiveService.favBoxName)
        .get('favorites', defaultValue: []),
  );

  // 2️⃣ HIVE → FIRESTORE
  await _db.collection('users').doc(uid).update({
    'favoriteRestaurants': hiveFavs,
  });

  // 3️⃣ FIRESTORE → GET
  final snap = await _db.collection('users').doc(uid).get();
  final serverFavs =
      List<String>.from(snap.data()?['favoriteRestaurants'] ?? []);

  // 4️⃣ FIRESTORE → HIVE
  await Hive.box(HiveService.favBoxName)
      .put('favorites', serverFavs);

  favoriteIds = serverFavs;

  favSyncLoading = false;
  notifyListeners();
}



  //============================================================

  // =================== FETCH & SAVE RESTAURANTS TO HIVE ===================

  bool restaurantsFetchedForHive = false;

  Future<void> fetchAndSaveRestaurants({bool forceRefresh = false}) async {
    if (restaurantsFetchedForHive && !forceRefresh) {
      return; // already saved
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .get();

      final List<Map<String, dynamic>> listToSave = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // 🔥 VERY IMPORTANT
        return data;
      }).toList();

      // 🔥 SAVE TO HIVE
      await HiveService().saveRestaurants(listToSave);

      restaurantsFetchedForHive = true;

      debugPrint('✅ Restaurants saved to Hive: ${listToSave.length}');
    } catch (e) {
      debugPrint('❌ Error saving restaurants to Hive: $e');
    }
  }

  // ================= Restaurant with logos ===================
  List<RestaurantModel> get restaurantsWithLogo {
    return restaurants
        // ignore: unnecessary_null_comparison
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
    {"image": "assets/png_images/food.png", "title": "New restaurants"},
    {"image": "assets/png_images/chef-hat.png", "title": "Homechef"},
    {"image": "assets/png_images/deal.png", "title": "Deals"},
    {"image": "assets/png_images/delivery-bike.png", "title": "Fast Delivery"},
  ];

  final List<String> images = [
    "https://cdn.pixabay.com/photo/2018/07/14/21/30/club-sandwich-3538455_1280.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7Fu9lPWkLE5L0gaBsRMxAfkSLHrjGXLn3gw&s",
    "https://media.istockphoto.com/id/2061716709/photo/grilled-rib-burger.jpg?s=612x612&w=0&k=20&c=QS37W9zjBE3GoOeR8ay3k_DS7oXPH07MBg-WHY5Joac=",
    "https://cdn.pixabay.com/photo/2020/10/05/21/30/hamburger-5630800_1280.jpg",
    "https://cdn.pixabay.com/photo/2022/07/15/18/12/cheese-burger-7323672_1280.jpg",
  ];

  final List<Map<String, dynamic>> categoryTitles = [
    // ya hai wo list
    {
      "title": "Pizza",
      "image":
          "https://www.foodandwine.com/thmb/iJw7N_NfcPpd-EB8rpYbzrkSFIM=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/tomato-mozzarella-pizza-FT-RECIPE0725-e7244e979c504188a049623668c15b2e.jpg",
    },
    {
      "title": "Burger",
      "image":
          "https://assets.epicurious.com/photos/5c745a108918ee7ab68daf79/1:1/w_2503,h_2503,c_limit/Smashburger-recipe-120219.jpg",
    },
    {
      "title": "Biryani",
      "image":
          "https://www.thespruceeats.com/thmb/XDBL9gA6A6nYWUdsRZ3QwH084rk=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/SES-chicken-biryani-recipe-7367850-hero-A-ed211926bb0e4ca1be510695c15ce111.jpg",
    },
    {
      "title": "Fast Food",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0cFleHkr83XTp-0AALLRqiAOs7nZxme-OVQ&s",
    },
    {
      "title": "Bakers",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScEJLoIhxNHhsa3EscR0gNoEyc6cmOH0NR6Q&s",
    },

     {
      "title": "Ice Cream",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBgIoSm8wGUVBmnZ9AjOflrCu0ycqUObRhVw&s",
    },
  ];

  HomeViewModel() {
    _loadUserFromHive();
    loadFavoritesFromHive();
    scroll.addListener(_scrollListener);
    startPromoTimer();
  }

  void _scrollListener() {
    final shouldStick = scroll.offset > 160;

    if (stickySearch.value != shouldStick) {
      stickySearch.value = shouldStick;
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
    _promoTimer?.cancel();
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

    // isSearchBarSticky = false;
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

  /// Reset sticky when leaving Home
  void resetSticky() {
    stickySearch.value = false;
  }

  void selectItem(String item) {
    if (selectedItem == item) {
      selectedItem = ""; // deselect
    } else {
      selectedItem = item;
    }
    notifyListeners();
  }

  void selectCategory(String category) {
    if (selectedCategory == category) {
      selectedCategory = ""; // deselect
    } else {
      selectedCategory = category;
    }
    notifyListeners();
  }

  List<RestaurantModel> get filteredRestaurants {
    if (selectedCategory.isEmpty) return restaurants;

    return restaurants.where((r) {
      final name = r.name.toLowerCase();
      final type = r.type.toLowerCase();
      final cat = selectedCategory.toLowerCase();

      return name.contains(cat) || type.contains(cat);
    }).toList();
  }


void showPromoWithDelay() {
  if (promoDismissed) return;

  Future.delayed(const Duration(seconds: 3), () {
    if (promoDismissed) return;

    promoVisible = true;
    startPromoTimer(); // ✅ Timer bhi start kar diya
    notifyListeners();
  });
}





  void dismissPromo() {
    promoDismissed = true;
    promoVisible = false;
    notifyListeners();
  }

Timer? _promoTimer;
int promoSeconds = 40 * 60; // 40 minutes

void startPromoTimer() {
  if (_promoTimer != null && _promoTimer!.isActive) return;

  promoVisible = true;
  _promoTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (promoSeconds > 0) {
      promoSeconds--;
      notifyListeners();
    } else {
      timer.cancel();
      promoVisible = false;
      notifyListeners();
    }
  });
}

void resetPromoTimer() {
  promoSeconds = 40 * 60;
  _promoTimer?.cancel();
  startPromoTimer();
  notifyListeners();
}


bool promoPopupShownThisSession = false;

bool canShowPromoPopup() {
  if (promoPopupShownThisSession) return false;

  promoPopupShownThisSession = true;
  return true;
}






}
