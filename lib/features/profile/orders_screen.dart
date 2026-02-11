import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../core/constants/app_colors.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: userOrders.length,
        itemBuilder: (context, index) {
          final order = userOrders[index];
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
                    Text("Order No:${order.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(order.date, style: const TextStyle(color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(order.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Status:", style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          Text(order.status, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text(order.amount, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
