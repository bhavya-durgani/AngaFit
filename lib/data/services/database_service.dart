import 'package:cloud_firestore/cloud_firestore.dart';  
// Imports Firestore database (used for storing and retrieving data)

import 'package:firebase_auth/firebase_auth.dart';  
// Imports Firebase Authentication (to get current user)

import '../dummy_data.dart';  
// Imports Product model/data

class DatabaseService {  
  // Service class to handle all database (Firestore) operations

  final FirebaseFirestore _db = FirebaseFirestore.instance;  
  // Get Firestore instance

  //  Use a getter so uid is always fresh, never null from stale construction
  String? get uid => FirebaseAuth.instance.currentUser?.uid;  
  // Always get latest logged-in user's UID

  // ─── Products ─────────────────────────────────────────────────────────────

  Stream<List<Product>> getProductsStream(String category) {  
    // Returns real-time list of products (filtered by category)

    Query query = _db.collection('products');  
    // Start with all products

    if (category != "All") {  
      // If specific category selected

      query = query.where('category', isEqualTo: category);  
      // Filter products by category
    }

    return query.snapshots().map((snapshot) =>  
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());  
    // Convert Firestore data into Product objects
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getCartStream() {  
    // Returns real-time cart data

    return _db.collection('users').doc(uid).collection('cart').snapshots();  
    // Path: users → userId → cart
  }

  Future<void> addToCart(Product p, String size, int qty) async {  
    // Add product to cart

    if (uid == null) return;  
    // Stop if user not logged in

    await _db.collection('users').doc(uid).collection('cart').doc(p.name).set({
      'name': p.name,  
      'brand': p.brand,  
      'price': p.price,  
      'imageUrl': p.imageUrl,  
      'size': size,  
      'quantity': qty,  
      'addedAt': FieldValue.serverTimestamp(),  
    });
  }

  Future<void> removeFromCart(String docId) async {  
    // Remove item from cart

    if (uid == null) return;

    await _db.collection('users').doc(uid).collection('cart').doc(docId).delete();  
  }

  Future<void> clearCart() async {  
    // Remove all items from cart

    if (uid == null) return;

    final cartDocs = await _db.collection('users').doc(uid).collection('cart').get();  
    // Get all cart items

    for (var doc in cartDocs.docs) {  
      // Loop through each item

      await doc.reference.delete();  
      // Delete each item
    }
  }

  Future<void> updateCartQuantity(String docId, int newQty) async {  
    // Update quantity of item in cart

    if (uid == null) return;

    if (newQty < 1) {  
      // If quantity becomes zero

      await removeFromCart(docId);  
      // Remove item
    } else {
      await _db.collection('users').doc(uid).collection('cart').doc(docId).update({
        'quantity': newQty,  
        // Update quantity
      });
    }
  }

  // ─── Favorites ─────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(Product p) async {  
    // Add/remove product from favorites

    if (uid == null) return;

    final ref = _db.collection('users').doc(uid).collection('favorites').doc(p.name);  
    // Reference to favorite item

    final doc = await ref.get();  
    // Check if already exists

    if (doc.exists) {  
      await ref.delete();  
      // If exists → remove from favorites
    } else {
      await ref.set({
        'name': p.name,
        'brand': p.brand,
        'price': p.price,
        'imageUrl': p.imageUrl,
        'description': p.description,
        'composition': p.composition,
        'care': p.care,
        'unityModelUrl': p.unityModelUrl,
        'availableSizes': p.availableSizes,
        'availableColors': p.availableColors,
      });
      // If not exists → add to favorites
    }
  }

  Stream<List<Product>> getFavoritesStream() {  
    // Get real-time favorite products

    return _db.collection('users').doc(uid).collection('favorites').snapshots()
        .map((snaps) => snaps.docs.map((doc) => Product.fromFirestore(doc)).toList());  
  }

  // ─── Orders ─────────────────────────────────────────────────────────────────

  /// Creates an order in Firestore.
  /// [paymentMethod]: "COD" | "QR" | etc.
  Future<String> createOrder(
    double total, {
    List<Map<String, dynamic>>? directItems,
    String? address,
    String paymentMethod = 'COD',
  }) async {
    // Function to create an order

    if (uid == null) throw "User not logged in";  
    // Ensure user is logged in

    List<Map<String, dynamic>> orderItems = [];  
    bool isFromCart = false;

    if (directItems != null && directItems.isNotEmpty) {  
      // If items passed directly

      orderItems = directItems;
    } else {
      final cartSnapshot =
          await _db.collection('users').doc(uid).collection('cart').get();  
      // Otherwise fetch items from cart

      orderItems = cartSnapshot.docs.map((doc) => doc.data()).toList();
      isFromCart = true;
    }

    if (orderItems.isEmpty) throw "No items to order";  
    // Prevent empty order

    final orderRef = _db.collection('users').doc(uid).collection('orders').doc();  
    // Create new order document

    final String orderId = orderRef.id;  
    // Get generated order ID

    await orderRef.set({
      'orderId': orderId,
      'items': orderItems,
      'total': total,
      'itemsCount': orderItems.length,
      'status': 'Pending',
      'paymentMethod': paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
      'deliveryAddress': address ?? '',
    });

    if (isFromCart) {  
      await clearCart();  
      // Clear cart after placing order
    }

    return orderId;  
    // Return order ID
  }

  Stream<QuerySnapshot> getOrdersStream() {  
    // Get user's orders

    return _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── Addresses ─────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getAddresses() {  
    // Get saved addresses

    return _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {  
    // Add new address

    if (uid == null) return;

    await _db.collection('users').doc(uid).collection('addresses').add({
      ...addressData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAddress(String addressId) async {  
    // Delete address

    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  Future<void> updateProfilePhoto(String url) async {  
    // Update profile image

    if (uid == null) return;

    await _db.collection('users').doc(uid).set({
      'profileImageUrl': url,
    }, SetOptions(merge: true));  
    // Merge = update only this field
  }

  // ─── Admin ─────────────────────────────────────────────────────────────────

  Future<void> deleteProduct(String id) async {  
    // Delete product (admin use)

    await _db.collection('products').doc(id).delete();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {  
    // Update product details (admin)

    await _db.collection('products').doc(id).update(data);
  }

  Stream<QuerySnapshot> getAllOrdersAdminStream() {  
    // Get all orders from all users (admin)

    return _db
        .collectionGroup('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus(DocumentReference orderRef, String newStatus) async {  
    // Update order status (admin)

    await orderRef.update({'status': newStatus});
  }
}
