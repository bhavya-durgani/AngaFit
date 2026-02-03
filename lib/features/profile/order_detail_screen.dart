import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool salesNotify = true;
  bool arrivalsNotify = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text("Personal Information", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInput("Full name", "Matilda Brown"),
            const SizedBox(height: 16),
            _buildInput("Date of Birth", "12/12/1989"),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => _showPasswordChange(context), child: const Text("Change", style: TextStyle(color: AppColors.grey))),
              ],
            ),
            _buildInput("Password", "********"),
            const SizedBox(height: 32),
            const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(title: const Text("Sales"), value: salesNotify, onChanged: (v) => setState(() => salesNotify = v), activeColor: AppColors.success),
            SwitchListTile(title: const Text("New arrivals"), value: arrivalsNotify, onChanged: (v) => setState(() => arrivalsNotify = v), activeColor: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showPasswordChange(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Text("Password Change", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const TextField(decoration: InputDecoration(labelText: "Old Password")),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: "New Password")),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: "Repeat New Password")),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("SAVE PASSWORD", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
