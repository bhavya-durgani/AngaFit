import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({super.key, required this.orderId, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Order Details"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order №$orderId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("Jan 30, 2026", style: TextStyle(color: AppColors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
                "Status: ${orderData['status']}",
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 30),
            const Text("Order information", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _infoRow("Total Amount:", "₹${orderData['total']}"),
            _infoRow("Items:", "${orderData['itemsCount']} items"),
            const Divider(height: 40),
            const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                "3 Newbridge Court, Chino Hills, CA 91709, USA",
                style: TextStyle(color: AppColors.grey, height: 1.4)
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("BACK TO ORDERS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.grey))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
