import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imgController = TextEditingController();
  String _category = "Women";

  Future<void> _uploadProduct() async {
    await FirebaseFirestore.instance.collection('products').add({
      'name': _nameController.text,
      'brand': "AngaFit Premium",
      'price': double.parse(_priceController.text),
      'imageUrl': _imgController.text,
      'category': _category,
      'description': "High quality material with AR support.",
      'composition': "100% Organic Cotton",
      'care': "Machine wash cold",
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Price (e.g. 1599)")),
            TextField(controller: _imgController, decoration: const InputDecoration(labelText: "Image URL")),
            DropdownButton<String>(
              value: _category,
              items: ["Women", "Men", "Kids"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const Spacer(),
            ElevatedButton(onPressed: _uploadProduct, child: const Text("SAVE TO FIREBASE")),
          ],
        ),
      ),
    );
  }
}
