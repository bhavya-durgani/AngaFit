import 'package:cloud_firestore/cloud_firestore.dart';  
// Imports Firestore (used to fetch product data)

class Product {  
  // Product model class (represents a single product)

  final String id, name, brand, imageUrl, description, composition, care, unityModelUrl;  
  // Product properties (basic info + AR model URL)

  final double price;  
  // Product price

  final List<String> availableSizes;  
  // List of sizes (S, M, L, etc.)

  final List<String> availableColors;  
  // List of available colors

  Product({
    this.id = '',  
    // Product ID (default empty if not provided)

    required this.name,  
    // Product name

    required this.brand,  
    // Brand name

    required this.price,  
    // Price

    required this.imageUrl,  
    // Image URL

    required this.description,  
    // Description

    required this.composition,  
    // Material details

    required this.care,  
    // Care instructions

    required this.unityModelUrl,  
    // 3D model URL (used in Unity AR)

    required this.availableSizes,  
    // Available sizes

    required this.availableColors,  
    // Available colors
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {  
    // Factory constructor to create Product from Firestore document

    Map data = doc.data() as Map<String, dynamic>;  
    // Convert Firestore data into Map

    return Product(
      id: doc.id,  
      // Document ID becomes product ID

      name: data['name'] ?? '',  
      // Get name (default empty if null)

      brand: data['brand'] ?? '',  
      // Get brand

      price: (data['price'] ?? 0).toDouble(),  
      // Convert price to double

      imageUrl: data['imageUrl'] ?? '',  
      // Get image URL

      description: data['description'] ?? '',  
      // Get description

      composition: data['composition'] ?? '',  
      // Get composition

      care: data['care'] ?? '',  
      // Get care instructions

      unityModelUrl: data['unityModelUrl'] ?? '',  
      // Get Unity model URL

      availableSizes: List<String>.from(data['availableSizes'] ?? []),  
      // Convert sizes list

      availableColors: List<String>.from(data['availableColors'] ?? []),  
      // Convert colors list
    );
  }
}

class Order {  
  // Simple Order model (used for displaying orders)

  final String id, date, status, amount, imageUrl;  
  // Order properties

  Order({
    required this.id,  
    required this.date,  
    required this.status,  
    required this.amount,  
    required this.imageUrl
  });
}

final List<String> appCategories = ["All", "Women", "Men", "Kids"];  
// List of product categories used in app (for filtering)
