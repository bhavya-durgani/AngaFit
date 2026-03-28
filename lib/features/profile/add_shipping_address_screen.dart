import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/database_service.dart';

class AddShippingAddressScreen extends StatefulWidget {
  const AddShippingAddressScreen({super.key});
  @override State<AddShippingAddressScreen> createState() => _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _streetCtrl  = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _stateCtrl   = TextEditingController();
  final _zipCtrl     = TextEditingController();
  String _selectedLabel = 'Home';
  bool _saving = false;

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await DatabaseService().addAddress({
        'label':  _selectedLabel,
        'name':   _nameCtrl.text.trim(),
        'street': _streetCtrl.text.trim(),
        'city':   _cityCtrl.text.trim(),
        'state':  _stateCtrl.text.trim(),
        'zip':    _zipCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Shipping Address'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Label', style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Home', 'Work', 'Office', 'Other'].map((lbl) {
                  final selected = _selectedLabel == lbl;
                  return ChoiceChip(
                    label: Text(lbl),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedLabel = lbl),
                    selectedColor: AppColors.primaryRed,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _field('Recipient Name', _nameCtrl),
              _field('Street Address', _streetCtrl),
              Row(
                children: [
                  Expanded(child: _field('City', _cityCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('ZIP Code', _zipCtrl, isNum: true)),
                ],
              ),
              _field('State / Province', _stateCtrl),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveAddress,
                  child: _saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('SAVE ADDRESS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
