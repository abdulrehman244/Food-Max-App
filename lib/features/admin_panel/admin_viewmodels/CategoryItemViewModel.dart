import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/CategoryService.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';

class AddCategoryItemViewModel extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  final itemName = TextEditingController();
  final itemPrice = TextEditingController();
  final itemOldPrice = TextEditingController(); // ✅ NEW
  final itemDescription = TextEditingController();
  final itemImage = TextEditingController();

  bool isLoading = false;

  Future<void> addItem(String restaurantId, String categoryId) async {
    if (itemName.text.isEmpty || itemPrice.text.isEmpty || itemImage.text.isEmpty) return;

    isLoading = true;
    notifyListeners();

    final item = CategoryItemModel(
      name: itemName.text,
      image: itemImage.text,
      price: double.tryParse(itemPrice.text) ?? 0,
      oldPrice: itemOldPrice.text.isNotEmpty
          ? double.tryParse(itemOldPrice.text)
          : null, // ✅ optional
      description: itemDescription.text,
      restaurantId: restaurantId,
      categoryId: categoryId,
    );

    await _service.addCategoryItem(restaurantId, categoryId, item);

    itemName.clear();
    itemPrice.clear();
    itemOldPrice.clear();
    itemDescription.clear();
    itemImage.clear();

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateItem(
    String restaurantId,
    String categoryId,
    String itemId,
    Map<String, dynamic> updatedData,
  ) async {
    await _service.updateCategoryItem(
      restaurantId,
      categoryId,
      itemId,
      updatedData,
    );
    notifyListeners();
  }

  Future<void> deleteItem(String restaurantId, String categoryId, String itemId) async {
    await _service.deleteCategoryItem(restaurantId, categoryId, itemId);
    notifyListeners();
  }

  Stream<List<CategoryItemModel>> getItemsStream(String restaurantId, String categoryId) {
    return _service.getCategoryItems(restaurantId, categoryId);
  }
}
