import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import '../../core/constants/app_colors.dart'; // App colors
import '../../data/services/database_service.dart'; // Database service

// Stateful screen to select address
class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key}); // Constructor

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

// State class
class _AddressSelectionScreenState extends State<AddressSelectionScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("Shipping Addresses"), // Title
        centerTitle: true
      ),

      // MAIN BODY
      body: StreamBuilder<QuerySnapshot>(

        // Get addresses from Firestore
        stream: DatabaseService().getAddresses(),

        builder: (context, snapshot) {

          // Show loading
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs; // Address documents

          // If no addresses exist
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  // Icon
                  const Icon(
                    Icons.location_off_outlined,
                    size: 64,
                    color: AppColors.grey
                  ),

                  const SizedBox(height: 16),

                  // Message
                  const Text(
                    "No addresses saved yet.",
                    style: TextStyle(color: AppColors.grey)
                  ),

                  const SizedBox(height: 24),

                  // Add new address button
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
            padding: const EdgeInsets.all(16),

            itemCount: docs.length,

            itemBuilder: (context, index) {

              final data = docs[index].data() as Map<String, dynamic>;

              // Build each address card
              return _buildAddressCard(docs[index].id, data);
            },
          );
        },
      ),

      // Bottom button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),

        child: ElevatedButton(
          onPressed: () => _showAddAddressDialog(context), // Open add dialog
          child: const Text("ADD NEW ADDRESS"),
        ),
      ),
    );
  }

  // Build each address card
  Widget _buildAddressCard(String id, Map<String, dynamic> data) {

    final String label = data['label'] ?? "Address"; // Label (Home/Work)

    // Full address string
    final String fullAddress =
        "${data['street']}, ${data['city']}, ${data['state']} ${data['zip']}";

    return GestureDetector(

      // When user taps → send selected address back
      onTap: () => Navigator.pop(context, {
        'label': label,
        'name': data['name'],
        'address': fullAddress,
      }),

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
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

            // Top row (label + delete button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                // Label (Home/Work/etc)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)
                  ),

                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 10
                    )
                  ),
                ),

                // Delete button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.grey,
                    size: 20
                  ),

                  onPressed: () => DatabaseService().deleteAddress(id),
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

            // Street
            Text(
              data['street'] ?? "",
              style: const TextStyle(color: AppColors.grey, fontSize: 14)
            ),

            // City + state + zip
            Text(
              "${data['city']}, ${data['state']} ${data['zip']}",
              style: const TextStyle(color: AppColors.grey, fontSize: 14)
            ),

            const Divider(height: 24),

            // Instruction text
            const Center(
              child: Text(
                "Tap to select",
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                )
              )
            ),
          ],
        ),
      ),
    );
  }

  // Show bottom sheet to add new address
  void _showAddAddressDialog(BuildContext context) {

    final formKey = GlobalKey<FormState>(); // Form key

    // Controllers for inputs
    final nameController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();

    String selectedLabel = "Home"; // Default label

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) => StatefulBuilder(

        // StatefulBuilder lets bottom sheet update UI
        builder: (context, setModalState) => Container(

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))
          ),

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

                  const Text(
                    "Add New Address",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),

                  const SizedBox(height: 20),

                  // Label selection
                  const Text(
                    "Address Label",
                    style: TextStyle(color: AppColors.grey, fontSize: 12)
                  ),

                  const SizedBox(height: 8),

                  // Chips for label
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,

                    children: ["Home", "Work", "Office", "Other"].map((label) {

                      bool isSelected = selectedLabel == label;

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,

                        // Update selected label
                        onSelected: (val) =>
                            setModalState(() => selectedLabel = label),

                        selectedColor: AppColors.primaryRed,

                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black
                        ),
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
                    validator: (v) => v!.isEmpty ? "Required" : null,
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

                  // City + ZIP
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
                          keyboardType: TextInputType.number,

                          validator: (v) =>
                              (v!.isEmpty || v.length < 5)
                                  ? "Invalid ZIP"
                                  : null,
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

                          // Save address to DB
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
