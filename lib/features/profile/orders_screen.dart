import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'order_details_screen.dart';

import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Orders"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text("No orders placed yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildOrderCard(context, docs[index].id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderId, Map<String, dynamic> data) {
    final DateTime? createdAt = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null;
    final String dateStr = createdAt != null ? DateFormat('dd-MM-yyyy HH:mm').format(createdAt) : "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Order ID: ${orderId.substring(0, 8).toUpperCase()}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(dateStr, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text("Quantity: ", style: TextStyle(color: AppColors.grey)),
              Text("${data['itemsCount'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text("Total: ", style: TextStyle(color: AppColors.grey)),
              Text("₹${data['total']}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (data['status'] == 'Delivered') ? AppColors.success.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data['status'] ?? "Pending",
                  style: TextStyle(
                    color: (data['status'] == 'Delivered') ? AppColors.success : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: orderId, orderData: data))
                ),
                child: const Text("VIEW DETAILS", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
