import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.price;
    }
    return total;
  }

  void addItem(Product product) {
    _items.add(product);
    notifyListeners(); // This tells the UI to refresh
  }

  void removeItem(String productName) {
    _items.removeWhere((item) => item.name == productName);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
