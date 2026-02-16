import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Orders"), centerTitle: true),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text("No orders placed yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              // Pass the ID and the Data map here
              return _buildOrderCard(context, docs[index].id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order №$orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text("Today", style: TextStyle(color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Use data['total'] from Firebase
              Text("Total Amount: ₹${data['total']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(data['status'] ?? "Processing", style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(
                      orderId: orderId,
                      orderData: data, // Pass the map to the details screen
                    )
                )
            ),
            child: const Text("Details"),
          )
        ],
      ),
    );
  }
}
