import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  
  bool isDefault = true;

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final batch = FirebaseFirestore.instance.batch();
    
    if (isDefault) {
      final allDocs = await FirebaseFirestore.instance.collection('users').doc(uid).collection('paymentMethods').get();
      for (var d in allDocs.docs) {
        batch.update(d.reference, {'isDefault': false});
      }
    }

    final newRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('paymentMethods').doc();
    batch.set(newRef, {
      'cardHolder': _nameCtrl.text.trim(),
      'cardNumber': _numCtrl.text.trim(),
      'expiryDate': _expCtrl.text.trim(),
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: AppColors.success,
            content: Text("Card added successfully!")
        ),
      );
    }
  }

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
              _buildInput("Name on card", "Jane Doe", _nameCtrl),
              const SizedBox(height: 16),
              _buildInput("Card number", "5546 8205 3693 3947", _numCtrl, isNum: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInput("Expiry Date", "05/23", _expCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInput("CVV", "567", _cvvCtrl, isNum: true)),
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
                  onPressed: _savePaymentMethod,
                  child: const Text("ADD CARD"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController controller, {bool isNum = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: TextFormField(
        controller: controller,
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
