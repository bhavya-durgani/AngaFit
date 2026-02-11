import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'add_shipping_address_screen.dart';

class ShippingAddressesScreen extends StatelessWidget {
  const ShippingAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Shipping Addresses")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _addressCard("Jane Doe", "3 Newbridge Court", "Chino Hills, CA 91709, USA", true),
          const SizedBox(height: 20),
          _addressCard("John Doe", "516 Center Dr", "Long Beach, NY 11561, USA", false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddShippingAddressScreen())),
        backgroundColor: AppColors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _addressCard(String name, String street, String city, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: AppColors.primaryRed) : null,
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
          const SizedBox(height: 8),
          Text(street),
          Text(city),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: isSelected ? AppColors.black : AppColors.grey),
              const SizedBox(width: 8),
              const Text("Use as the shipping address"),
            ],
          )
        ],
      ),
    );
  }
}
