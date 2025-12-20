import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/CategoryService.dart';
import 'package:food_delivery_app/data/models/CategoryModel.dart';

class AddCategoryNameViewModel extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  final categoryName = TextEditingController();
  bool isLoading = false;

  Future<void> addCategory(String restaurantId) async {
    if (categoryName.text.isEmpty) return;

    isLoading = true;
    notifyListeners();

    final category = CategoryModel(id: '', name: categoryName.text, items: []);
    await _service.addCategory(restaurantId, category);

    categoryName.clear();
    isLoading = false;
    notifyListeners();
  }

  Stream<List<CategoryModel>> getCategories(String restaurantId) {
    return _service.getCategories(restaurantId);
  }
}
