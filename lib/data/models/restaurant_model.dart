class RestaurantModel {
  String id;
  String name;
  double rating;
  double deliveryFee;
  String deliveryTime;
  String type;
  String image;
  String? logo;
  String location;

  RestaurantModel({
    this.id = '',
    required this.name,
    required this.rating,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.type,
    required this.image,
    required this.logo,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'type': type,
      'image': image,
      'logo': logo,
      'location': location,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map, String id) {
    return RestaurantModel(
      id: id,
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      deliveryTime: map['deliveryTime'] ?? '',
      type: map['type'] ?? '',
      image: map['image'] ?? '',
      logo: map['logo'] != null && map['logo'].toString().isNotEmpty
        ? map['logo']
        : null,
      location: map['location'] ?? '',
    );
  }
}
