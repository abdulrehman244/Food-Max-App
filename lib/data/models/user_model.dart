class UserModel {
  final String uid;
 String name;
  final String email;
  final Map<String, dynamic>? location;
  final List<String> favoriteRestaurants;
  final List<Map<String, dynamic>> cartItems;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.location,
    this.favoriteRestaurants = const [],
    this.cartItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'location': location ?? '',
      'favoriteRestaurants': favoriteRestaurants,
      'cartItems': cartItems,
    };
  }

factory UserModel.fromMap(Map<String, dynamic> map) {
  List<String> safeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> safeMapList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  return UserModel(
    uid: map['uid'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    location: map['location'] != null ? Map<String, dynamic>.from(map['location']) : null,
    favoriteRestaurants: safeStringList(map['favoriteRestaurants']),
    cartItems: safeMapList(map['cartItems']), // ✅ fix
  );
}




}
