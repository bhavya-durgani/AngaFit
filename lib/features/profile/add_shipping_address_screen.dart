import 'package:flutter/material.dart'; // Flutter UI framework
import '../../core/constants/app_colors.dart'; // App color constants
import '../../data/services/database_service.dart'; // Database service for saving address

// Stateful widget for adding a shipping address
class AddShippingAddressScreen extends StatefulWidget {
  const AddShippingAddressScreen({super.key}); // Constructor

  @override 
  State<AddShippingAddressScreen> createState() => _AddShippingAddressScreenState(); // Create state
}

// State class
class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Controllers for text fields
  final _nameCtrl    = TextEditingController(); // Recipient name
  final _streetCtrl  = TextEditingController(); // Street address
  final _cityCtrl    = TextEditingController(); // City
  final _stateCtrl   = TextEditingController(); // State/Province
  final _zipCtrl     = TextEditingController(); // ZIP code

  String _selectedLabel = 'Home'; // Default label (Home/Work/etc)
  bool _saving = false; // Loading state while saving

  // Function to save address
  Future<void> _saveAddress() async {

    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true); // Show loading

    try {
      // Call database service to save address
      await DatabaseService().addAddress({
        'label':  _selectedLabel, // Address label
        'name':   _nameCtrl.text.trim(), // Name input
        'street': _streetCtrl.text.trim(), // Street input
        'city':   _cityCtrl.text.trim(), // City input
        'state':  _stateCtrl.text.trim(), // State input
        'zip':    _zipCtrl.text.trim(), // ZIP input
      });

      // Go back after saving
      if (mounted) Navigator.pop(context);

    } catch (e) {
      // Show error if saving fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }

    } finally {
      // Stop loading
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text('Add Shipping Address'), // Screen title
        centerTitle: true, // Center title
      ),

      body: SingleChildScrollView( // Scrollable screen
        padding: const EdgeInsets.all(20), // Padding

        child: Form(
          key: _formKey, // Attach form key

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Left align content

            children: [

              // Label title
              const Text(
                'Label',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
                )
              ),

              const SizedBox(height: 8), // Spacing

              // Choice chips for address type
              Wrap(
                spacing: 8, // Space between chips

                children: ['Home', 'Work', 'Office', 'Other'].map((lbl) {
                  final selected = _selectedLabel == lbl; // Check if selected

                  return ChoiceChip(
                    label: Text(lbl), // Chip text
                    selected: selected, // Selected state

                    onSelected: (_) => setState(() => _selectedLabel = lbl), // Update selection

                    selectedColor: AppColors.primaryRed, // Selected color

                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black // Text color based on selection
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Input fields
              _field('Recipient Name', _nameCtrl), // Name field
              _field('Street Address', _streetCtrl), // Street field

              // Row for City + ZIP
              Row(
                children: [
                  Expanded(child: _field('City', _cityCtrl)), // City
                  const SizedBox(width: 12),
                  Expanded(child: _field('ZIP Code', _zipCtrl, isNum: true)), // ZIP numeric
                ],
              ),

              _field('State / Province', _stateCtrl), // State field

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity, // Full width

                child: ElevatedButton(
                  onPressed: _saving ? null : _saveAddress, // Disable when saving

                  child: _saving
                      // Show loader if saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white
                          )
                        )
                      // Normal text
                      : const Text('SAVE ADDRESS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable input field widget
  Widget _field(String label, TextEditingController ctrl, {bool isNum = false}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 14), // Spacing between fields

      child: TextFormField(
        controller: ctrl, // Attach controller

        keyboardType: isNum
            ? TextInputType.number // Numeric keyboard
            : TextInputType.text, // Text keyboard

        // Validation
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Required' : null,

        decoration: InputDecoration(
          labelText: label, // Field label
          filled: true,
          fillColor: Colors.white, // Background color

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded border
            borderSide: BorderSide.none, // No border line
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14
          ),
        ),
      ),
    );
  }
}
