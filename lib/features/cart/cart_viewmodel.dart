import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';

class CartViewModel extends ChangeNotifier {
  final HiveService _cartService = HiveService();

  /// cart list jo UI ko milegi
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;


  bool _showSheet = false;
  bool get showSheet => _showSheet;

  Map<String, dynamic>? _selectedItem;
  Map<String, dynamic>? get selectedItem => _selectedItem;

  // 🔥 TEMP QUANTITY (Item detail ke liye)
  int _tempQuantity = 1;
  int get tempQuantity => _tempQuantity;

  // ================= QUANTITY CONTROLS =================
  bool isSwitched = false;

  void toggle(bool value) {
    isSwitched = value;
    notifyListeners();
  }

  void increaseQuantity() {
    _tempQuantity++;
    notifyListeners();
  }

  void decreaseQuantity() {
    if (_tempQuantity > 1) {
      _tempQuantity--;
      notifyListeners();
    }
  }

  void updateItemQuantity(String name, int newQuantity) {
    for (var item in _cartItems) {
      if (item['name'] == name) {
        item['quantity'] = newQuantity;
        _cartService.updateItemQuantity(name, newQuantity); // ✅ Hive me update
        break;
      }
    }
    notifyListeners();
  }

  void resetQuantity() {
    _tempQuantity = 1;
    notifyListeners();
  }

  // ========================== SHOW BOTTOM SHEET =================
  void openSheet(Map<String, dynamic> item) {
    _selectedItem = item;
    _showSheet = true;
    notifyListeners();
  }

  void closeSheet() {
    _selectedItem = null;
    _showSheet = false;
    notifyListeners();
  }

  //================================================================

  //====================
  /// LOAD CART FROM HIVE
  /// ==========================
  void loadCart() {
    _cartItems = _cartService.getCartItems();
    notifyListeners();
  }

  /// ==========================
  /// ADD ITEM
  /// ==========================
  void addToCart({
    required String name,
    required String image,
    required double price,
  }) {
    _cartService.addItemToCart(
      name: name,
      image: image,
      price: price,
      quantity: _tempQuantity,
    );
    loadCart();
  }

  /// ==========================
  /// REMOVE ITEM
  /// ==========================
  void removeFromCart(String name) {
    _cartService.removeItemFromCart(name);
    loadCart();
    closeSheet();
  }

  /// ==========================
  /// CLEAR CART (LOGOUT)
  /// ==========================
  void clearCart() {
    _cartService.clearCartOnLogout();
    _cartItems = [];
    notifyListeners();
  }

  /// ==========================
  /// TOTAL PRICE (OPTIONAL)
  /// ==========================
  /// 

  

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item['price'] * item['quantity'] + 114;
    }
    return total;
  }

  double get finalTotal {
  double total = totalPrice;

  if (isSwitched) {
    total -= 200;
  }

  if (total < 0) total = 0; // safety

  return total;
}

}
