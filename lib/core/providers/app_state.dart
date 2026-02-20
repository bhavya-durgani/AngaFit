import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/dummy_data.dart';

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  AppState() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // LOGIC: Add Product to Firebase and notify UI
  Future<void> addToBag(Product product, String size, int qty) async {
    if (_user == null) return;

    await _db.collection('users').doc(_user!.uid).collection('cart').doc(product.name).set({
      'name': product.name,
      'brand': product.brand,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'size': size,
      'quantity': qty,
      'addedAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  // LOGIC: Delete from Bag
  Future<void> removeFromBag(String productName) async {
    await _db.collection('users').doc(_user!.uid).collection('cart').doc(productName).delete();
    notifyListeners();
  }
}
