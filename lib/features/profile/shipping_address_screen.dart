import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ShippingAddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Shipping Addresses")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAddressCard("Jane Doe", "3 Newbridge Court", "Chino Hills, CA 91709, United States", true),
            const SizedBox(height: 20),
            _buildAddressCard("Jane Doe", "3 Newbridge Court", "Chino Hills, CA 91709, United States", false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAddressCard(String name, String street, String city, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [if (isSelected) BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text("Edit", style: TextStyle(color: AppColors.primaryRed)),
            ],
          ),
          const SizedBox(height: 12),
          Text(street),
          Text(city),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(value: isSelected, onChanged: (v) {}, activeColor: AppColors.black),
              const Text("Use as the shipping address"),
            ],
          )
        ],
      ),
    );
  }
}
