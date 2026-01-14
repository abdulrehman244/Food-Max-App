import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';
import 'package:food_delivery_app/data/models/CategoryModel.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Category
  Future<void> addCategory(String restaurantId, CategoryModel category) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .add(category.toMap());
  }

  // Update Category
  Future<void> updateCategory(String restaurantId, String categoryId, String newName) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .doc(categoryId)
        .update({'name': newName});
  }

  // Delete Category
  Future<void> deleteCategory(String restaurantId, String categoryId) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  // Get Categories
  Stream<List<CategoryModel>> getCategories(String restaurantId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add Category Item
  Future<void> addCategoryItem(String restaurantId, String categoryId, CategoryItemModel item) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .doc(categoryId)
        .collection('items')
        .add(item.toMap());
  }

  // Update Category Item
  Future<void> updateCategoryItem(
      String restaurantId, String categoryId, String itemId, Map<String, dynamic> updatedData) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .doc(categoryId)
        .collection('items')
        .doc(itemId)
        .update(updatedData);
  }

  // Delete Category Item
  Future<void> deleteCategoryItem(String restaurantId, String categoryId, String itemId) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .doc(categoryId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  // Get Category Items
  Stream<List<CategoryItemModel>> getCategoryItems(String restaurantId, String categoryId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .doc(categoryId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
