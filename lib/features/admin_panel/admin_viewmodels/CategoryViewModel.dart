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

    final category = CategoryModel(
      id: '', 
      name: categoryName.text,
      restaurantId: restaurantId, 
      items: [],
    );
    await _service.addCategory(restaurantId, category);

    categoryName.clear();
    isLoading = false;
    notifyListeners();
  }

  // ✅ Update Category
  Future<void> updateCategory(String restaurantId, String categoryId, String newName) async {
    await _service.updateCategory(restaurantId, categoryId, newName);
    notifyListeners();
  }

  // ✅ Delete Category
  Future<void> deleteCategory(String restaurantId, String categoryId) async {
    await _service.deleteCategory(restaurantId, categoryId);
    notifyListeners();
  }

  Stream<List<CategoryModel>> getCategories(String restaurantId) {
    return _service.getCategories(restaurantId);
  }
}
