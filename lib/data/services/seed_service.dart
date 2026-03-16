import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  static Future<void> seedProducts() async {
    try {
      final products = [
        {
          'name': 'Casual Denim Jacket',
          'brand': 'Levi\'s',
          'price': 3499.0,
          'category': 'Men',
          'imageUrl': 'https://images.unsplash.com/photo-1576872381149-7847515ce5d8',
          'unityModelUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/main/2.0/CesiumMan/glTF-Binary/CesiumMan.glb',
          'unityModelName': 'denim_jacket',
          'description': 'Classic denim jacket with a comfortable fit.',
          'composition': 'Denim',
          'care': 'Hand wash recommended',
          'availableSizes': ['M', 'L', 'XL', 'XXL'],
          'availableColors': ['Blue', 'Black'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Classic White T-Shirt',
          'brand': 'Zara',
          'price': 799.0,
          'category': 'Women',
          'imageUrl': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
          'unityModelUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/main/2.0/CesiumMan/glTF-Binary/CesiumMan.glb',
          'unityModelName': 'white_tshirt',
          'description': 'Simple and elegant white t-shirt.',
          'composition': 'Cotton',
          'care': 'Tumble dry low',
          'availableSizes': ['XS', 'S', 'M', 'L'],
          'availableColors': ['White'],
          'createdAt': FieldValue.serverTimestamp(),

        },
      ];

      final collection = FirebaseFirestore.instance.collection('products');
      
      for (var product in products) {
        await collection.doc(product['name'] as String).set(product);
      }
    } catch (e) {
      print("Error seeding products: $e");
      rethrow;
    }
  }
}