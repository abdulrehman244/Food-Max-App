import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';

class CartService {
  final box = Hive.box("cartBox");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> updateFullCartToFirebase() async {
    if (_uid == null) return;

    final cartItems = box.get(_uid, defaultValue: []);
    final List<Map<String, dynamic>> cartList =
        List<Map<String, dynamic>>.from(
      (cartItems as List).map((e) => Map<String, dynamic>.from(e)),
    );

    await _firestore.collection('users').doc(_uid).set(
      {
        'cart': cartList,
      },
      SetOptions(merge: true),
    );
  }
}     
