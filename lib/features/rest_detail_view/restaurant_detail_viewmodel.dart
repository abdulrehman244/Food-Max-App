import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/CategoryService.dart';
import 'package:food_delivery_app/data/models/CategoryModel.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';

class RestaurantDetailViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = true;

  final List<StreamSubscription> _subscriptions = [];

  void loadCategories(String restaurantId) {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();

    var sub = _categoryService.getCategories(restaurantId).listen((catList) {
      // Assign restaurantId to each category
      categories = catList.map((c) => CategoryModel(
        id: c.id,
        name: c.name,
        restaurantId: restaurantId,
        items: [],
      )).toList();

      if (!disposed) notifyListeners();

      for (var category in categories) {
        var itemSub = _categoryService
            .getCategoryItems(restaurantId, category.id)
            .listen((items) {
          // Assign restaurantId and categoryId to each item
          category.items = items.map((item) => CategoryItemModel(
            id: item.id,
            name: item.name,
            image: item.image,
            price: item.price,
            oldPrice: item.oldPrice,
            description: item.description,
            restaurantId: restaurantId,
            categoryId: category.id,
          )).toList();

          // Save category + items in Hive
          _saveCategoryWithItems(category);

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

  void _saveCategoryWithItems(CategoryModel category) {
    final hive = HiveService();
    // Save category
    hive.saveRestaurants([category.toMap()]);
    
  }
}
