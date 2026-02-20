import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddShippingAddressScreen extends StatelessWidget {
  const AddShippingAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Adding Shipping Address")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _input("Full name"),
            const SizedBox(height: 16),
            _input("Address"),
            const SizedBox(height: 16),
            _input("City"),
            const SizedBox(height: 16),
            _input("State/Province/Region"),
            const SizedBox(height: 16),
            _input("Zip Code"),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("SAVE ADDRESS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: TextField(decoration: InputDecoration(labelText: label, border: InputBorder.none)),
    );
  }
}
