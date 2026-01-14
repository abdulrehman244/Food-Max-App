class RestaurantModel {
  final String id;
  final String name;
  final double rating;
  final double deliveryFee;
  final String deliveryTime;
  final String type;
  final String image;
  final String logo;
  final Map<String, dynamic> location; // <-- change from String to Map

  RestaurantModel({
    required this.id,
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
      'location': location, // <-- map save ho rahi hai
    };
  }

factory RestaurantModel.fromMap(Map<String, dynamic> map, String id) {
  Map<String, dynamic> loc = {};

  if (map['location'] != null) {
    if (map['location'] is Map<String, dynamic>) {
      loc = Map<String, dynamic>.from(map['location']);
    } else if (map['location'] is String) {
      loc = {
        "address": map['location'],
        "lat": 0.0,
        "lng": 0.0,
      };
    }
  }

  return RestaurantModel(
    id: id,
    name: map['name'] ?? '',
    rating: (map['rating'] ?? 0).toDouble(),
    deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
    deliveryTime: map['deliveryTime'] ?? '',
    type: map['type'] ?? '',
    image: map['image'] ?? '',
    logo: map['logo'] ?? '',
    location: loc,
  );
}




}
