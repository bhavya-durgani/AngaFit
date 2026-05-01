import 'package:flutter/material.dart';  
// Imports Flutter material package (needed for ChangeNotifier)

import '../../data/dummy_data.dart';  
// Imports Product model/data used in the cart

class CartProvider with ChangeNotifier {  
  // CartProvider manages cart data and notifies UI when changes happen

  final List<Product> _items = [];  
  // Private list to store cart items

  List<Product> get items => _items;  
  // Getter to access cart items outside the class

  double get totalAmount {  
    // Calculates total price of all items in cart

    double total = 0.0;  
    // Initialize total amount

    for (var item in _items) {  
      // Loop through each product in cart

      total += item.price;  
      // Add price of each item to total
    }

    return total;  
    // Return final total amount
  }

  void addItem(Product product) {  
    // Function to add product to cart

    _items.add(product);  
    // Add product to list

    notifyListeners();  
    // Notify UI to refresh after adding item
  }

  void removeItem(String productName) {  
    // Function to remove product from cart using its name

    _items.removeWhere((item) => item.name == productName);  
    // Remove item where product name matches

    notifyListeners();  
    // Notify UI to refresh after removal
  }

  void clearCart() {  
    // Function to remove all items from cart

    _items.clear();  
    // Clear the list

    notifyListeners();  
    // Notify UI to refresh after clearing cart
  }
}
