import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name, brand, imageUrl, description, composition, care;
  final double price;
  final List<String> availableSizes;
  final List<String> availableColors;

  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.composition,
    required this.care,
    required this.availableSizes,
    required this.availableColors,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? 'No description provided.',
      composition: data['composition'] ?? '100% Cotton',
      care: data['care'] ?? 'Machine wash cold',
      // NEW FIELDS
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      availableColors: List<String>.from(data['availableColors'] ?? []),
    );
  }
}

class Order {
  final String id, date, status, amount, imageUrl;
  Order({required this.id, required this.date, required this.status, required this.amount, required this.imageUrl});
}

final List<String> appCategories = ["All", "Women", "Men", "Kids"];
