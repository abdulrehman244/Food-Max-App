// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/data/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _userCollection = "users";

   Future<Map<String, dynamic>?> loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection("users").doc(user.uid).get();
    if (!doc.exists) return null;

    return doc.data();
  }

  Future<void> createUser(UserModel user) async {
    try {
      print("UserService: Creating user ${user.uid}");
      await _firestore.collection(_userCollection).doc(user.uid).set(user.toMap());
      print("UserService: User created successfully");
    } catch (e) {
      print("UserService createUser error: $e");
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      User? firebaseUser = _auth.currentUser;
      print("UserService: Current Firebase user: ${firebaseUser?.uid}");
      if (firebaseUser == null) return null;

      DocumentSnapshot doc = await _firestore.collection(_userCollection).doc(firebaseUser.uid).get();
      print("UserService: User document exists: ${doc.exists}");
      if (!doc.exists) return null;
      print("UserService: Firestore doc data: ${doc.data()}");
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("UserService getCurrentUser error: $e");
      return null;
    }
  }

  Stream<UserModel?> streamUser(String uid) {
    try {
      return _firestore.collection(_userCollection).doc(uid).snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        return UserModel.fromMap(snapshot.data()!);
      });
    } catch (e) {
      print("UserService streamUser error: $e");
      rethrow;
    }
  }

  Future<void> toggleFavoriteRestaurant(String uid, String restaurantId, List<String> currentFavorites) async {
    try {
      List<String> updatedFavorites = List.from(currentFavorites);
      if (currentFavorites.contains(restaurantId)) {
        updatedFavorites.remove(restaurantId);
      } else {
        updatedFavorites.add(restaurantId);
      }
      await _firestore.collection(_userCollection).doc(uid).update({
        "favoriteRestaurants": updatedFavorites,
      });
    } catch (e) {
      print("UserService toggleFavoriteRestaurant error: $e");
      rethrow;
    }
  }

  Future<void> sendOrderNotification(String uid, String orderId) async {
    try {
      await _firestore.collection(_userCollection).doc(uid).collection('notifications').add({
        'title': 'Order Confirmed',
        'body': 'Your order is on the way!',
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("UserService sendOrderNotification error: $e");
      rethrow;
    }
  }

  Future<void> addFavorite(String restaurantId) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'favoriteRestaurants': FieldValue.arrayUnion([restaurantId])
      });
    } catch (e) {
      print("UserService addFavorite error: $e");
      rethrow;
    }
  }

  Future<void> removeFavorite(String restaurantId) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'favoriteRestaurants': FieldValue.arrayRemove([restaurantId])
      });
    } catch (e) {
      print("UserService removeFavorite error: $e");
      rethrow;
    }
  }

  Future<List<String>> getfavoriteRestaurants() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return List<String>.from(doc['favoriteRestaurants'] ?? []);
    } catch (e) {
      print("UserService getfavoriteRestaurants error: $e");
      return [];
    }
  }
}
