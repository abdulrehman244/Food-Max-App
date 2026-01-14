import 'package:food_delivery_app/data/models/CategoryItemModel.dart';

class CategoryModel {
  String id;
  String name;
  String restaurantId; // Add this
  List<CategoryItemModel> items;

  CategoryModel({
    this.id = '',
    required this.name,
    required this.restaurantId,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'restaurantId': restaurantId, // save restaurant id
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      items: [], // items fetch separately
    );
  }
}
