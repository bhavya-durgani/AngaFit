import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key}); // Added const constructor

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool salesNotify = true;
  bool arrivalsNotify = false;
  bool deliveryNotify = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              "Personal Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildInput("Full name", "Matilda Brown"),
            const SizedBox(height: 16),
            _buildInput("Date of Birth", "12/12/1989"),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Password",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => _showPasswordChange(context),
                  child: const Text("Change", style: TextStyle(color: AppColors.grey)),
                ),
              ],
            ),
            _buildInput("Password", "********"),
            const SizedBox(height: 32),
            const Text(
              "Notifications",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildSwitchTile("Sales", salesNotify, (v) => setState(() => salesNotify = v)),
            _buildSwitchTile("New arrivals", arrivalsNotify, (v) => setState(() => arrivalsNotify = v)),
            _buildSwitchTile("Delivery status changes", deliveryNotify, (v) => setState(() => deliveryNotify = v)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.success,
    );
  }

  void _showPasswordChange(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          height: 450,
          child: Column(
            children: [
              Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              const Text("Password Change", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const TextField(decoration: InputDecoration(labelText: "Old Password", filled: true, fillColor: Colors.white)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: "New Password", filled: true, fillColor: Colors.white)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: "Repeat New Password", filled: true, fillColor: Colors.white)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("SAVE PASSWORD"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
