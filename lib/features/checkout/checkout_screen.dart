import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'payment_selection_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final double total;
  final int count;

  const CheckoutScreen({super.key, required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Order Summary"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shipping Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildCard("Jane Doe", "3 Newbridge Court, Chino Hills, CA 91709, USA"),
            const SizedBox(height: 28),
            const Text("Order Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _summaryRow("Items in Cart", "$count"),
                  const Divider(),
                  _summaryRow("Total Payable", "₹${total.toStringAsFixed(0)}", isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentSelectionScreen(totalAmount: total)),
                ),
                child: const Text("CONTINUE TO PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _summaryRow(String l, String v, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(v, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: FontWeight.bold, color: isBold ? AppColors.primaryRed : AppColors.black)),
        ],
      ),
    );
  }
}
