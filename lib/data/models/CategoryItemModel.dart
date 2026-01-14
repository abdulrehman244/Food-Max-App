class CategoryItemModel {
  String id;
  String name;
  String image;
  double price;
  double? oldPrice; 
  String description;
  String restaurantId;
  String categoryId;

  CategoryItemModel({
    this.id = '',
    required this.name,
    required this.image,
    required this.price,
    this.oldPrice, 
    required this.description,
    required this.restaurantId,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      if (oldPrice != null) 'oldPrice': oldPrice, 
      'description': description,
      'restaurantId': restaurantId,
      'categoryId': categoryId,
    };
  }

  factory CategoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryItemModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      oldPrice: map['oldPrice'] != null
          ? (map['oldPrice'] as num).toDouble()
          : null, // ✅ safe for old data
      description: map['description'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      categoryId: map['categoryId'] ?? '',
    );
  }
}
