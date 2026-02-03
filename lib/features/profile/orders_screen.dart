import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Orders")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) => _buildOrderItem(),
      ),
    );
  }

  Widget _buildOrderItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order №1947034", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("05-12-2019", style: TextStyle(color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 15),
          const Row(
            children: [
              Text("Tracking number: ", style: TextStyle(color: AppColors.grey)),
              Text("IW3475453455", style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [Text("Quantity: ", style: TextStyle(color: AppColors.grey)), Text("3")]),
              const Row(children: [Text("Total Amount: ", style: TextStyle(color: AppColors.grey)), Text("USD 112")]),
              Text("Delivered", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          OutlinedButton(onPressed: () {}, child: const Text("Details"))
        ],
      ),
    );
  }
}
