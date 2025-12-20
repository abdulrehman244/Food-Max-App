import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';
import 'package:food_delivery_app/data/models/CategoryModel.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCategory(String restaurantId, CategoryModel category) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .add(category.toMap());
  }

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

  Future<void> addCategoryItem(String restaurantId, String categoryId, CategoryItemModel item) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('categories')
        .doc(categoryId)
        .collection('items')
        .add(item.toMap());
  }

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
