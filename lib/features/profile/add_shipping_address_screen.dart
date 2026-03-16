import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class AddShippingAddressScreen extends StatefulWidget {
  const AddShippingAddressScreen({super.key});
  @override State<AddShippingAddressScreen> createState() => _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  Future<void> _saveAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty || _cityCtrl.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
       return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).collection('addresses').add({
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'zip': _zipCtrl.text.trim(),
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

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
            _input("Full name", _nameCtrl),
            const SizedBox(height: 16),
            _input("Address", _addressCtrl),
            const SizedBox(height: 16),
            _input("City", _cityCtrl),
            const SizedBox(height: 16),
            _input("State/Province/Region", _stateCtrl),
            const SizedBox(height: 16),
            _input("Zip Code", _zipCtrl),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAddress,
                child: const Text("SAVE ADDRESS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label, border: InputBorder.none)
      ),
    );
  }
}
