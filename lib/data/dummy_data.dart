import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name, brand, imageUrl, description, composition, care;
  final double price;

  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.composition,
    required this.care,
  });

  // This is the logic that reads the product you added in the console
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? 'No description available.',
      composition: data['composition'] ?? '100% Cotton',
      care: data['care'] ?? 'Machine wash cold',
    );
  }
}

class Order {
  final String id, date, status, amount, imageUrl;
  Order({required this.id, required this.date, required this.status, required this.amount, required this.imageUrl});
}

// Global Category List
final List<String> appCategories = ["All", "Women", "Men", "Kids"];

// Order History (Dummy for now)
final List<Order> userOrders = [
  Order(id: "1947034", date: "05-12-2025", status: "Delivered", amount: "₹4,112", imageUrl: "https://images.unsplash.com/photo-1539109136881-3be0616acf4b"),
];
