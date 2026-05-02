import 'package:flutter/material.dart'; // Imports Flutter UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package
import '../../core/constants/app_colors.dart'; // Custom app color constants
import 'add_shipping_address_screen.dart'; // Screen for adding new address (not used directly here)
import '../../data/services/database_service.dart'; // Service class for database operations

// Stateful widget because UI changes dynamically (data updates from Firestore)
class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Set background color
      appBar: AppBar(title: const Text("Shipping Addresses"), centerTitle: true), // Top app bar

      // StreamBuilder listens to real-time Firestore updates
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getAddresses(), // Fetch addresses stream from database
        builder: (context, snapshot) {

          // If no data yet → show loader
          if (!snapshot.hasData) 
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs; // Extract documents list

          // If no addresses saved
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 64, color: AppColors.grey), // Empty state icon
                  const SizedBox(height: 16),
                  const Text("No addresses saved yet.", style: TextStyle(color: AppColors.grey)), // Message
                  const SizedBox(height: 24),

                  // Button to add new address
                  ElevatedButton(
                    onPressed: () => _showAddAddressDialog(context), 
                    child: const Text("ADD NEW ADDRESS")
                  ),
                ],
              ),
            );
          }

          // If addresses exist → show list
          return ListView.builder(
            padding: const EdgeInsets.all(16), // Outer padding
            itemCount: docs.length, // Total number of addresses

            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>; // Extract each address data

              return _buildAddressCard(docs[index].id, data); // Build card UI
            },
          );
        },
      ),

      // Bottom button to add new address
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _showAddAddressDialog(context), // Open bottom sheet
          child: const Text("ADD NEW ADDRESS"),
        ),
      ),
    );
  }

  // Widget to display each address card
  Widget _buildAddressCard(String id, Map<String, dynamic> data) {

    final String label = data['label'] ?? "Address"; // Get label (Home/Work/etc)

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Space between cards
      padding: const EdgeInsets.all(16), // Inner padding
      decoration: BoxDecoration(
        color: Colors.white, // Card background
        borderRadius: BorderRadius.circular(16), // Rounded corners
        boxShadow: [ // Shadow effect
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Top row → Label + Delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Address label chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  label.toUpperCase(), // Convert to uppercase
                  style: const TextStyle(
                    color: AppColors.primaryRed, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 10
                  )
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.grey, size: 20),
                onPressed: () => DatabaseService().deleteAddress(id), // Delete from database
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            data['name'] ?? "", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),

          const SizedBox(height: 4),

          // Street address
          Text(
            data['street'] ?? "", 
            style: const TextStyle(color: AppColors.grey, fontSize: 14)
          ),

          // City + State + ZIP
          Text(
            "${data['city']}, ${data['state']} ${data['zip']}", 
            style: const TextStyle(color: AppColors.grey, fontSize: 14)
          ),
        ],
      ),
    );
  }

  // Function to show bottom sheet for adding address
  void _showAddAddressDialog(BuildContext context) {

    final formKey = GlobalKey<FormState>(); // Form validation key

    // Controllers to capture user input
    final nameController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();

    String selectedLabel = "Home"; // Default label

    // Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full height with keyboard
      backgroundColor: Colors.transparent,

      builder: (context) => StatefulBuilder( // Allows state updates inside modal
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))
          ),

          // Padding with keyboard adjustment
          padding: EdgeInsets.only(
            left: 24, 
            right: 24, 
            top: 24, 
            bottom: MediaQuery.of(context).viewInsets.bottom + 24
          ),

          child: Form(
            key: formKey,

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text("Add New Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  const Text("Address Label", style: TextStyle(color: AppColors.grey, fontSize: 12)),

                  const SizedBox(height: 8),

                  // Label selection chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ["Home", "Work", "Office", "Other"].map((label) {

                      bool isSelected = selectedLabel == label;

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (val) => setModalState(() => selectedLabel = label), // Update label
                        selectedColor: AppColors.primaryRed,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Name input
                  TextFormField(
                    controller: nameController, 
                    decoration: const InputDecoration(
                      labelText: "Recipient Name*", 
                      hintText: "e.g. John Doe"
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null, // Validation
                  ),

                  // Street input
                  TextFormField(
                    controller: streetController, 
                    decoration: const InputDecoration(
                      labelText: "Street Address*", 
                      hintText: "House No, Street Name"
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  // City + ZIP in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cityController, 
                          decoration: const InputDecoration(labelText: "City*"),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        )
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: TextFormField(
                          controller: zipController, 
                          decoration: const InputDecoration(labelText: "Zip Code*"),
                          keyboardType: TextInputType.number, // Numeric keyboard
                          validator: (v) => (v!.isEmpty || v.length < 5) ? "Invalid ZIP" : null,
                        )
                      ),
                    ],
                  ),

                  // State input
                  TextFormField(
                    controller: stateController, 
                    decoration: const InputDecoration(labelText: "State/Province*"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {

                        // Validate form
                        if (formKey.currentState!.validate()) {

                          // Save to database
                          await DatabaseService().addAddress({
                            'label': selectedLabel,
                            'name': nameController.text,
                            'street': streetController.text,
                            'city': cityController.text,
                            'state': stateController.text,
                            'zip': zipController.text,
                          });

                          // Close bottom sheet
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text("SAVE ADDRESS"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
