import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dummy_data.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ FIX: Use a getter so uid is always fresh, never null from stale construction
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // ─── Products ─────────────────────────────────────────────────────────────

  Stream<List<Product>> getProductsStream(String category) {
    Query query = _db.collection('products');
    if (category != "All") {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getCartStream() {
    return _db.collection('users').doc(uid).collection('cart').snapshots();
  }

  Future<void> addToCart(Product p, String size, int qty) async {
    if (uid == null) return;
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
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('cart').doc(docId).delete();
  }

  Future<void> clearCart() async {
    if (uid == null) return;
    final cartDocs = await _db.collection('users').doc(uid).collection('cart').get();
    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateCartQuantity(String docId, int newQty) async {
    if (uid == null) return;
    if (newQty < 1) {
      await removeFromCart(docId);
    } else {
      await _db.collection('users').doc(uid).collection('cart').doc(docId).update({
        'quantity': newQty,
      });
    }
  }

  // ─── Favorites ─────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(Product p) async {
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('favorites').doc(p.name);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
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
    }
  }

  Stream<List<Product>> getFavoritesStream() {
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
    if (uid == null) throw "User not logged in";

    List<Map<String, dynamic>> orderItems = [];
    bool isFromCart = false;

    if (directItems != null && directItems.isNotEmpty) {
      orderItems = directItems;
    } else {
      final cartSnapshot =
          await _db.collection('users').doc(uid).collection('cart').get();
      orderItems = cartSnapshot.docs.map((doc) => doc.data()).toList();
      isFromCart = true;
    }

    if (orderItems.isEmpty) throw "No items to order";

    final orderRef = _db.collection('users').doc(uid).collection('orders').doc();
    final String orderId = orderRef.id;

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
    }

    return orderId;
  }

  Stream<QuerySnapshot> getOrdersStream() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── Addresses ─────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getAddresses() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('addresses').add({
      ...addressData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAddress(String addressId) async {
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
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'profileImageUrl': url,
    });
  }

  // ─── Admin ─────────────────────────────────────────────────────────────────

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.collection('products').doc(id).update(data);
  }

  Stream<QuerySnapshot> getAllOrdersAdminStream() {
    return _db
        .collectionGroup('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus(DocumentReference orderRef, String newStatus) async {
    await orderRef.update({'status': newStatus});
  }
}
