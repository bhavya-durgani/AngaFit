import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddShippingAddressScreen extends StatelessWidget {
  const AddShippingAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Adding Shipping Address"),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField("Full name"),
            const SizedBox(height: 16),
            _buildTextField("Address"),
            const SizedBox(height: 16),
            _buildTextField("City"),
            const SizedBox(height: 16),
            _buildTextField("State/Province/Region"),
            const SizedBox(height: 16),
            _buildTextField("Zip Code (Postal Code)"),
            const SizedBox(height: 16),
            _buildTextField("Country"),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Address saved successfully!")),
                  );
                },
                child: const Text("SAVE ADDRESS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
