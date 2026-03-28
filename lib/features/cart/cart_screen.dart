import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/database_service.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Bag"), centerTitle: true),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getCartStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Your bag is empty"));

          double total = 0;
          for (var doc in docs) {
            total += (doc['price'] ?? 0) * (doc['quantity'] ?? 1);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildCartItem(context, docs[index].id, data);
                  },
                ),
              ),
              _buildSummary(context, total, docs.length),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, String docId, Map<String, dynamic> data) {
    int qty = data['quantity'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12), 
            child: Image.network(data['imageUrl'], width: 80, height: 100, fit: BoxFit.cover)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("Size: ${data['size']}", style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹${data['price'].toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryRed)),
                    Row(
                      children: [
                        _qtyBtn(Icons.remove, () => DatabaseService().updateCartQuantity(docId, qty - 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        _qtyBtn(Icons.add, () => DatabaseService().updateCartQuantity(docId, qty + 1)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed, size: 20), 
            onPressed: () => DatabaseService().removeFromCart(docId)
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double subtotal, int count) {
    final double tax = subtotal * 0.05;
    final double deliveryFee = subtotal >= 5000 ? 0 : 50.0;
    final double total = subtotal + tax + deliveryFee;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow("Subtotal", "₹${subtotal.toStringAsFixed(0)}"),
          _summaryRow("Tax (5%)", "₹${tax.toStringAsFixed(0)}"),
          _summaryRow("Delivery Fee", deliveryFee == 0 ? "Free" : "₹${deliveryFee.toStringAsFixed(0)}"),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Payable", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("₹${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, 
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => CheckoutScreen(total: subtotal, count: count))
              ), 
              child: const Text("CHECK OUT"),
            )
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
