import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderData
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order №$orderId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(
                "Status: ${orderData['status'] ?? 'Processing'}",
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 30),
            const Text("Order information", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _infoRow("Total Amount:", "₹${orderData['total']}"),
            _infoRow("Items:", "${orderData['itemsCount'] ?? 0} items"),
            _infoRow("Date:", "Jan 30, 2026"),
            const Divider(height: 40),
            const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                "3 Newbridge Court, Chino Hills, CA 91709, USA",
                style: TextStyle(color: AppColors.grey)
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
