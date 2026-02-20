import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isDefault = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Add new card")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildInput("Name on card", "Jane Doe"),
              const SizedBox(height: 16),
              _buildInput("Card number", "5546 8205 3693 3947", isNum: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInput("Expiry Date", "05/23")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput("CVV", "567", isNum: true)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                      value: isDefault,
                      activeColor: AppColors.black,
                      onChanged: (v) => setState(() => isDefault = v!)
                  ),
                  const Text("Set as default payment method"),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text("Card added successfully!")
                        ),
                      );
                    }
                  },
                  child: const Text("ADD CARD"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, {bool isNum = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: TextFormField(
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
