import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _updateProfile() async {
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name", filled: true, fillColor: Colors.white),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("SAVE CHANGES"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
