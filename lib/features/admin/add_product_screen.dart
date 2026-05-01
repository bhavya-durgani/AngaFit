import 'package:flutter/material.dart';  
// Imports Flutter UI components

import 'package:cloud_firestore/cloud_firestore.dart';  
// Imports Firestore (used to store product data)

class AddProductScreen extends StatefulWidget {  
  // Screen for admin to add a new product

  const AddProductScreen({super.key});  

  @override 
  State<AddProductScreen> createState() => _AddProductScreenState();  
  // Creates state object for this screen
}

class _AddProductScreenState extends State<AddProductScreen> {  
  // State class (handles UI + logic)

  final _nameController = TextEditingController();  
  // Controller for product name input

  final _priceController = TextEditingController();  
  // Controller for price input

  final _imgController = TextEditingController();  
  // Controller for image URL input

  String _category = "Women";  
  // Default category selected

  Future<void> _uploadProduct() async {  
    // Function to upload product to Firestore

    await FirebaseFirestore.instance.collection('products').add({
      'name': _nameController.text,  
      // Get product name from input

      'brand': "AngaFit Premium",  
      // Default brand name

      'price': double.parse(_priceController.text),  
      // Convert price text to double

      'imageUrl': _imgController.text,  
      // Get image URL

      'category': _category,  
      // Selected category

      'description': "High quality material with AR support.",  
      // Default description

      'composition': "100% Organic Cotton",  
      // Material info

      'care': "Machine wash cold",  
      // Care instructions
    });

    if (!mounted) return;  
    // Check if widget is still active (avoid errors)

    Navigator.pop(context);  
    // Go back to previous screen after saving
  }

  @override
  Widget build(BuildContext context) {  
    // Builds UI of screen

    return Scaffold(  
      // Main screen structure

      appBar: AppBar(title: const Text("Admin: Add Product")),  
      // Top bar with title

      body: Padding(
        padding: const EdgeInsets.all(20),  
        // Add spacing around content

        child: Column(
          // Vertical layout

          children: [

            TextField(
              controller: _nameController,  
              decoration: const InputDecoration(labelText: "Product Name")
            ),  
            // Input field for product name

            TextField(
              controller: _priceController,  
              decoration: const InputDecoration(labelText: "Price (e.g. 1599)")
            ),  
            // Input field for price

            TextField(
              controller: _imgController,  
              decoration: const InputDecoration(labelText: "Image URL")
            ),  
            // Input field for image URL

            DropdownButton<String>(
              value: _category,  
              // Current selected category

              items: ["Women", "Men", "Kids"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),  
              // Create dropdown options

              onChanged: (v) => setState(() => _category = v!),  
              // Update category when user selects new value
            ),

            const Spacer(),  
            // Push button to bottom

            ElevatedButton(
              onPressed: _uploadProduct,  
              // Call upload function on click

              child: const Text("SAVE TO FIREBASE")
            ),  
            // Button to save product
          ],
        ),
      ),
    );
  }
}
