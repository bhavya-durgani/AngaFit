import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order №1947034", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Text("Tracking number: IW3475453455", style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 30),
            const Text("Order information", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _infoRow("Shipping Address:", "3 Newbridge Court, Chino Hills, CA 91709, USA"),
            _infoRow("Payment Method:", "**** **** **** 3947"),
            _infoRow("Total Amount:", "₹4,112"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
