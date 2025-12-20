import 'package:food_delivery_app/data/models/CategoryItemModel.dart';

class CategoryModel {
  String id;
  String name;
  List<CategoryItemModel> items;

  CategoryModel({
    this.id = '',
    required this.name,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      items: [], // items fetch separately
    );
  }
}
