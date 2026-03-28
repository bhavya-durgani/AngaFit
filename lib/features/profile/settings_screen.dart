import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _auth = LocalAuthentication();

  final _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    if (_uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();
    if (!mounted) return;
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
      });
    }
  }



  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _updateProfile() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // 1. Handle password change with re-authentication
      if (_newPasswordController.text.isNotEmpty) {
        if (_currentPasswordController.text.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-current-pwd',
            message: 'Please enter your current password to set a new one.',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);
      }

      // 2. Sync display name to FirebaseAuth so it appears everywhere immediately
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && user.displayName != newName) {
        await user.updateDisplayName(newName);
      }

      // 3. Persist all prefs to Firestore
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'name': newName,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Settings saved!'),
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text(e.message ?? 'Failed to update profile'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text('An error occurred: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Personal Information ──────────────────────────────────────
            const Text('Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 30),

            // ── Change Password ───────────────────────────────────────────
            const Text('Change Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('To change your password, provide your current password.',
                style: TextStyle(fontSize: 12, color: AppColors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Leave blank to keep current',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),



            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('SAVE CHANGES'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
