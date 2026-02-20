import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dummy_data.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // FETCH PRODUCTS: Real-time from Firestore
  Stream<List<Product>> getProductsStream(String category) {
    Query query = _db.collection('products');
    if (category != "All") {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // CART LOGIC: User-specific sub-collection
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

  // FAVORITES LOGIC: User-specific sub-collection
  Future<void> toggleFavorite(Product p) async {
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('favorites').doc(p.name);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'name': p.name, 'brand': p.brand, 'price': p.price, 'imageUrl': p.imageUrl,
        'description': p.description, 'composition': p.composition, 'care': p.care,
        'availableSizes': p.availableSizes, 'availableColors': p.availableColors
      });
    }
  }

  Stream<List<Product>> getFavoritesStream() {
    return _db.collection('users').doc(uid).collection('favorites').snapshots()
        .map((snaps) => snaps.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }
}
