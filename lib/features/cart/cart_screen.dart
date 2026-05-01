import 'package:flutter/material.dart'; // Flutter UI library
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import '../../core/constants/app_colors.dart'; // App colors file
import '../../data/services/database_service.dart'; // Database helper service
import '../checkout/checkout_screen.dart'; // Checkout screen

// Stateless widget for Cart screen
class CartScreen extends StatelessWidget {
  const CartScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {

    // Get current logged-in user
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("My Bag"), // Title of screen
        centerTitle: true // Center align title
      ),

      // If user not logged in → show message
      body: user == null
          ? const Center(child: Text("Please login"))

          // If logged in → show cart data
          : StreamBuilder<QuerySnapshot>(

        // Listen to cart data from Firestore
        stream: DatabaseService().getCartStream(),

        builder: (context, snapshot) {

          // Show loading while data is coming
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get documents (cart items)
          final docs = snapshot.data!.docs;

          // If cart empty
          if (docs.isEmpty) {
            return const Center(child: Text("Your bag is empty"));
          }

          // Calculate total price
          double total = 0;
          for (var doc in docs) {
            total += (doc['price'] ?? 0) * (doc['quantity'] ?? 1);
          }

          // Main UI
          return Column(
            children: [

              // List of cart items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16), // Padding

                  itemCount: docs.length, // Number of items

                  itemBuilder: (context, index) {

                    // Get each item data
                    final data = docs[index].data() as Map<String, dynamic>;

                    // Build each cart item UI
                    return _buildCartItem(context, docs[index].id, data);
                  },
                ),
              ),

              // Bottom summary section
              _buildSummary(context, total, docs.length),
            ],
          );
        },
      ),
    );
  }

  // Function to build each cart item
  Widget _buildCartItem(BuildContext context, String docId, Map<String, dynamic> data) {

    int qty = data['quantity'] ?? 1; // Get quantity

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Space between items
      padding: const EdgeInsets.all(12), // Inner spacing

      decoration: BoxDecoration(
        color: Colors.white, // Background
        borderRadius: BorderRadius.circular(16), // Rounded corners

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Light shadow
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),

      child: Row(
        children: [

          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              data['imageUrl'], // Image URL
              width: 80,
              height: 100,
              fit: BoxFit.cover
            )
          ),

          const SizedBox(width: 16), // Space

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // Product name
                Text(
                  data['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis // Shorten if long
                ),

                // Product size
                Text(
                  "Size: ${data['size']}",
                  style: const TextStyle(color: AppColors.grey, fontSize: 13)
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    // Price
                    Text(
                      "₹${data['price'].toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryRed
                      )
                    ),

                    // Quantity controls
                    Row(
                      children: [

                        // Decrease button
                        _qtyBtn(
                          Icons.remove,
                          () => DatabaseService().updateCartQuantity(docId, qty - 1)
                        ),

                        // Quantity text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "$qty",
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                        ),

                        // Increase button
                        _qtyBtn(
                          Icons.add,
                          () => DatabaseService().updateCartQuantity(docId, qty + 1)
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete item button
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.primaryRed,
              size: 20
            ),
            onPressed: () => DatabaseService().removeFromCart(docId) // Remove item
          ),
        ],
      ),
    );
  }

  // Quantity button (reuse for + and -)
  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // Action on tap

      child: Container(
        padding: const EdgeInsets.all(4),

        decoration: BoxDecoration(
          shape: BoxShape.circle, // Circular shape
          border: Border.all(color: Colors.grey.shade300) // Border
        ),

        child: Icon(icon, size: 16), // Icon
      ),
    );
  }

  // Bottom summary section
  Widget _buildSummary(BuildContext context, double subtotal, int count) {

    final double tax = subtotal * 0.05; // 5% tax
    final double deliveryFee = subtotal >= 5000 ? 0 : 50.0; // Free delivery if >= 5000
    final double total = subtotal + tax + deliveryFee; // Final amount

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 20 // Adjust for safe area
      ),

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Rounded top
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)]
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          // Subtotal row
          _summaryRow("Subtotal", "₹${subtotal.toStringAsFixed(0)}"),

          // Tax row
          _summaryRow("Tax (5%)", "₹${tax.toStringAsFixed(0)}"),

          // Delivery row
          _summaryRow(
            "Delivery Fee",
            deliveryFee == 0 ? "Free" : "₹${deliveryFee.toStringAsFixed(0)}"
          ),

          const Divider(height: 32), // Line

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Total Payable",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),

              Text(
                "₹${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed
                )
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Checkout button
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(
                    total: subtotal, // Passing subtotal
                    count: count // Passing item count
                  )
                )
              ),
              child: const Text("CHECK OUT"),
            )
          ),
        ],
      ),
    );
  }

  // Row used for summary (label + value)
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)), // Label
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)), // Value
        ],
      ),
    );
  }
}
