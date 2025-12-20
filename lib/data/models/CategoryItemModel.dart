class CategoryItemModel {
  String id;
  String name;
  String image;
  double price;
  String description;

  CategoryItemModel({
    this.id = '',
    required this.name,
    required this.image,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,                                // ✔️ FIXED
      'name': name,
      'image': image,
      'price': price,
      'description': description,
    };
  }

  factory CategoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryItemModel(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
    );
  }
}
