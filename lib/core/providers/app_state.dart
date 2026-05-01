import 'package:flutter/material.dart';  
// Imports Flutter UI package (needed for ChangeNotifier)

import 'package:cloud_firestore/cloud_firestore.dart';  
// Imports Firebase Firestore (used for database operations)

import 'package:firebase_auth/firebase_auth.dart';  
// Imports Firebase Authentication (used for user login)

import '../../data/dummy_data.dart';  
// Imports Product model/data used in the app

class AppState extends ChangeNotifier {  
  // AppState class manages global app data and notifies UI when data changes

  final FirebaseAuth _auth = FirebaseAuth.instance;  
  // Get instance of Firebase Authentication

  final FirebaseFirestore _db = FirebaseFirestore.instance;  
  // Get instance of Firestore database

  User? _user;  
  // Private variable to store current logged-in user

  User? get user => _user;  
  // Getter to access user outside the class

  AppState() {  
    // Constructor runs when AppState is created

    _auth.authStateChanges().listen((user) {  
      // Listen for login/logout changes

      _user = user;  
      // Update current user

      notifyListeners();  
      // Notify UI to rebuild when user changes
    });
  }

  // LOGIC: Add Product to Firebase and notify UI
  Future<void> addToBag(Product product, String size, int qty) async {  
    // Function to add product to cart

    if (_user == null) return;  
    // If no user is logged in, do nothing

    await _db.collection('users')  
        .doc(_user!.uid)  
        // Access document of current user

        .collection('cart')  
        // Access user's cart collection

        .doc(product.name)  
        // Use product name as document ID

        .set({
      'name': product.name,  
      // Store product name

      'brand': product.brand,  
      // Store brand name

      'price': product.price,  
      // Store product price

      'imageUrl': product.imageUrl,  
      // Store product image

      'size': size,  
      // Store selected size

      'quantity': qty,  
      // Store quantity

      'addedAt': FieldValue.serverTimestamp(),  
      // Store time when product was added (server time)
    });

    notifyListeners();  
    // Notify UI to update after adding item
  }

  // LOGIC: Delete from Bag
  Future<void> removeFromBag(String productName) async {  
    // Function to remove product from cart

    await _db.collection('users')  
        .doc(_user!.uid)  
        // Access current user document

        .collection('cart')  
        // Access cart collection

        .doc(productName)  
        // Select product by name

        .delete();  
        // Delete that product

    notifyListeners();  
    // Notify UI to refresh after deletion
  }
}
