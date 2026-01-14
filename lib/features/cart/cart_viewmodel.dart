import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';

class CartViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _cart = [];
  List<Map<String, dynamic>> get cart => _cart;

  CartViewModel() {
    loadCart();
  }


/// ================= REFRESH CART =================
Future<void> refreshCart() async {
  await loadCart(); // Cart load karke _cart update karenge
}

/// ================= PLACE ORDER =================
Future<void> placeOrder(String restaurantId) async {
  // HiveService se order place karo
  await HiveService().placeOrderForRestaurant(restaurantId: restaurantId);

  // Cart reload karo taake UI update ho
  await refreshCart(); 
}



/// ================= INCREASE QTY =================
Future<void> increaseQty(String restaurantId, String itemId) async {
  final restIndex = _cart.indexWhere((r) => r['restaurantId'] == restaurantId);
  if (restIndex != -1) {
    final items = List<Map<String, dynamic>>.from(_cart[restIndex]['items']);
    final itemIndex = items.indexWhere((i) => i['itemId'] == itemId);
    if (itemIndex != -1) {
      items[itemIndex]['qty'] = (items[itemIndex]['qty'] ?? 1) + 1;
      _cart[restIndex]['items'] = items;
      await _saveFullCart();
      notifyListeners();
    }
  }
}

  bool isSwitched = false;

  void toggleSwitch(bool value) {
    isSwitched = value;
    notifyListeners();
  }

/// ================= DECREASE QTY =================
Future<void> decreaseQty(String restaurantId, String itemId) async {
  final restIndex = _cart.indexWhere((r) => r['restaurantId'] == restaurantId);
  if (restIndex != -1) {
    final items = List<Map<String, dynamic>>.from(_cart[restIndex]['items']);
    final itemIndex = items.indexWhere((i) => i['itemId'] == itemId);
    if (itemIndex != -1) {
      final currentQty = items[itemIndex]['qty'] ?? 1;
      if (currentQty > 1) {
        items[itemIndex]['qty'] = currentQty - 1;
      } else {
        // remove item if qty == 1
        items.removeAt(itemIndex);
      }

      if (items.isEmpty) {
        _cart.removeAt(restIndex);
      } else {
        _cart[restIndex]['items'] = items;
      }

      await _saveFullCart();
      notifyListeners();
    }
  }
}




  /// ✅ Check if item is already in cart
  bool isItemInCart(String itemId) {
    for (var rest in _cart) {
      final items = List<Map<String, dynamic>>.from(rest['items'] ?? []);
      if (items.any((i) => i['itemId'] == itemId)) return true;
    }
    return false;
  }


  /// ================= LOAD CART =================
Future<void> loadCart() async {
  _cart.clear();

  final box = Hive.box(HiveService.cartBoxName);
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
  final stored = box.get('cart_$uid');

  if (stored != null && stored is Map) {
    stored.forEach((key, value) {
      try {
        final restMap = Map<String, dynamic>.from(value as Map);
        final items = (restMap['items'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        restMap['items'] = items;
        _cart.add(restMap);
      } catch (e) {
        debugPrint("Cart parse error: $e");
      }
    });
  }

  notifyListeners();
}


  /// ================= ADD TO CART =================
  Future<void> addToCart({
    required String restaurantId,
    required String restaurantName,
    required String restaurantImage,
    required Map<String, dynamic> restaurantLocation,
    required Map<String, dynamic> item,
  }) async {
    final restIndex =
        _cart.indexWhere((r) => r['restaurantId'] == restaurantId);

    if (restIndex != -1) {
      final items =
          List<Map<String, dynamic>>.from(_cart[restIndex]['items']);

      final itemIndex =
          items.indexWhere((i) => i['itemId'] == item['itemId']);

      if (itemIndex != -1) {
        items[itemIndex]['qty'] =
            (items[itemIndex]['qty'] ?? 1) + (item['qty'] ?? 1);
      } else {
        items.add(item);
      }

      _cart[restIndex]['items'] = items;
    } else {
      _cart.add({
        "restaurantId": restaurantId,
        "restaurantName": restaurantName,
        "restaurantImage": restaurantImage,
        "restaurantLocation": restaurantLocation,
        "items": [item],
      });
    }

    await _saveFullCart();
    notifyListeners();
  }

  /// ================= REMOVE ITEM =================
  Future<void> removeItem(String itemId) async {
    _cart.removeWhere((rest) {
      rest['items'].removeWhere((i) => i['itemId'] == itemId);
      return rest['items'].isEmpty;
    });

    await _saveFullCart();
    notifyListeners();
  }

  

  /// ================= REMOVE RESTAURANT =================
  Future<void> removeRestaurant(String restaurantId) async {
    _cart.removeWhere((r) => r['restaurantId'] == restaurantId);
    await _saveFullCart();
    notifyListeners();
  }

  /// ================= SAVE TO HIVE =================
  Future<void> _saveFullCart() async {
    final Map<String, dynamic> map = {};
    for (var rest in _cart) {
      map[rest['restaurantId']] = rest;
    }

    final box = Hive.box(HiveService.cartBoxName);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
    await box.put('cart_$uid', map);
  }
}
