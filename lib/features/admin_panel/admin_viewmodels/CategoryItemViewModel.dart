import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/services/CategoryService.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';

class AddCategoryItemViewModel extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  final itemName = TextEditingController();
  final itemPrice = TextEditingController();
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
      description: itemDescription.text,
    );

    await _service.addCategoryItem(restaurantId, categoryId, item);

    itemName.clear();
    itemPrice.clear();
    itemDescription.clear();
    itemImage.clear();

    isLoading = false;
    notifyListeners();
  }

  Stream<List<CategoryItemModel>> getItemsStream(String restaurantId, String categoryId) {
    return _service.getCategoryItems(restaurantId, categoryId);
  }
}
