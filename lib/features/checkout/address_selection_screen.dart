import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/database_service.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Shipping Addresses"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getAddresses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text("No addresses saved yet.", style: TextStyle(color: AppColors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => _showAddAddressDialog(context), child: const Text("ADD NEW ADDRESS")),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildAddressCard(docs[index].id, data);
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _showAddAddressDialog(context),
          child: const Text("ADD NEW ADDRESS"),
        ),
      ),
    );
  }

  Widget _buildAddressCard(String id, Map<String, dynamic> data) {
    final String label = data['label'] ?? "Address";
    final String fullAddress = "${data['street']}, ${data['city']}, ${data['state']} ${data['zip']}";

    return GestureDetector(
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryRed.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(label.toUpperCase(), style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.grey, size: 20),
                  onPressed: () => DatabaseService().deleteAddress(id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(data['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(data['street'] ?? "", style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            Text("${data['city']}, ${data['state']} ${data['zip']}", style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            const Divider(height: 24),
            const Center(child: Text("Tap to select", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();
    String selectedLabel = "Home";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add New Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Label Selection
                  const Text("Address Label", style: TextStyle(color: AppColors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ["Home", "Work", "Office", "Other"].map((label) {
                      bool isSelected = selectedLabel == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (val) => setModalState(() => selectedLabel = label),
                        selectedColor: AppColors.primaryRed,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: nameController, 
                    decoration: const InputDecoration(labelText: "Recipient Name*", hintText: "e.g. John Doe"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: streetController, 
                    decoration: const InputDecoration(labelText: "Street Address*", hintText: "House No, Street Name"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
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
                          validator: (v) => (v!.isEmpty || v.length < 5) ? "Invalid ZIP" : null,
                        )
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: stateController, 
                    decoration: const InputDecoration(labelText: "State/Province*"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await DatabaseService().addAddress({
                            'label': selectedLabel,
                            'name': nameController.text,
                            'street': streetController.text,
                            'city': cityController.text,
                            'state': stateController.text,
                            'zip': zipController.text,
                          });
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
