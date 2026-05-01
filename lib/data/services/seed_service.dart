import 'package:cloud_firestore/cloud_firestore.dart';  
// Imports Firestore database (used to store product data)

class SeedService {  
  // Service class used to insert initial/sample data into database

  static Future<void> seedProducts() async {  
    // Function to add predefined products into Firestore

    try {  
      // Try block to handle errors safely

      final products = [  
        // List of product data (dummy/sample products)

        {
          'name': 'Casual Denim Jacket',  
          // Product name

          'brand': 'Levi\'s',  
          // Brand name

          'price': 3499.0,  
          // Price of product

          'category': 'Men',  
          // Category (used for filtering)

          'imageUrl': 'https://images.unsplash.com/photo-1576872381149-7847515ce5d8',  
          // Product image URL

          'unityModelUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/main/2.0/CesiumMan/glTF-Binary/CesiumMan.glb',  
          // 3D model URL (used in Unity AR)

          'unityModelName': 'denim_jacket',  
          // Name of Unity model

          'description': 'Classic denim jacket with a comfortable fit.',  
          // Product description

          'composition': 'Denim',  
          // Material details

          'care': 'Hand wash recommended',  
          // Care instructions

          'availableSizes': ['M', 'L', 'XL', 'XXL'],  
          // Available sizes

          'availableColors': ['Blue', 'Black'],  
          // Available colors

          'createdAt': FieldValue.serverTimestamp(),  
          // Timestamp when product is added
        },

        {
          'name': 'Classic White T-Shirt',  
          // Second product name

          'brand': 'Zara',  
          // Brand

          'price': 799.0,  
          // Price

          'category': 'Women',  
          // Category

          'imageUrl': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',  
          // Image URL

          'unityModelUrl': 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/main/2.0/CesiumMan/glTF-Binary/CesiumMan.glb',  
          // 3D model URL

          'unityModelName': 'white_tshirt',  
          // Model name

          'description': 'Simple and elegant white t-shirt.',  
          // Description

          'composition': 'Cotton',  
          // Material

          'care': 'Tumble dry low',  
          // Care instructions

          'availableSizes': ['XS', 'S', 'M', 'L'],  
          // Sizes

          'availableColors': ['White'],  
          // Colors

          'createdAt': FieldValue.serverTimestamp(),  
          // Timestamp
        },
      ];

      final collection = FirebaseFirestore.instance.collection('products');  
      // Reference to "products" collection in Firestore
      
      for (var product in products) {  
        // Loop through each product in list

        await collection.doc(product['name'] as String).set(product);  
        // Add product to Firestore using product name as document ID
      }

    } catch (e) {  
      // Catch any error

      print("Error seeding products: $e");  
      // Print error in console

      rethrow;  
      // Throw error again (so it can be handled elsewhere)
    }
  }
}
