import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/CategoryService.dart';
import 'package:food_delivery_app/data/models/CategoryModel.dart';

class RestaurantDetailViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = true;

  final List<StreamSubscription> _subscriptions = [];

  void loadCategories(String restaurantId) {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();

    var sub = _categoryService.getCategories(restaurantId).listen((catList) {
      categories = catList;
      if (!disposed) notifyListeners();

      for (var category in categories) {
        var itemSub = _categoryService
            .getCategoryItems(restaurantId, category.id)
            .listen((items) {
          category.items = items;
          if (!disposed) notifyListeners();
        });
        _subscriptions.add(itemSub);
      }

      isLoading = false;
      if (!disposed) notifyListeners();
    });

    _subscriptions.add(sub);
  }

  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    super.dispose();
  }
}
