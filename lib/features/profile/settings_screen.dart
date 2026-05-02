import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:local_auth/local_auth.dart'; // For biometric authentication (fingerprint/face)
import 'package:permission_handler/permission_handler.dart'; // To handle device permissions
import '../../core/constants/app_colors.dart'; // Custom app colors

// Stateful widget because we manage form state and loading
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controllers to manage input fields
  final _nameController = TextEditingController(); // Name field
  final _currentPasswordController = TextEditingController(); // Current password
  final _newPasswordController = TextEditingController(); // New password

  final _auth = LocalAuthentication(); // Biometric auth instance (not used yet)

  // Get current user UID
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Load user data when screen opens
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // ── Load User Profile ─────────────────────────────────────────────

  Future<void> _loadProfile() async {
    if (_uid == null) return; // If user not logged in, exit

    // Fetch user document from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();

    if (!mounted) return; // Ensure widget is still active

    if (doc.exists) {
      // Convert document data to Map
      final data = doc.data() as Map<String, dynamic>;

      // Update UI with fetched data
      setState(() {
        _nameController.text = data['name'] ?? '';
      });
    }
  }

  // ── Save / Update Profile ─────────────────────────────────────────

  Future<void> _updateProfile() async {
    if (_uid == null) return; // If no user, exit

    setState(() => _isLoading = true); // Show loading indicator

    try {
      final user = FirebaseAuth.instance.currentUser!; // Get current user

      // 1. Handle password change
      if (_newPasswordController.text.isNotEmpty) {
        // If user wants to change password

        if (_currentPasswordController.text.isEmpty) {
          // Current password required for security
          throw FirebaseAuthException(
            code: 'missing-current-pwd',
            message: 'Please enter your current password to set a new one.',
          );
        }

        // Create credential using current password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        // Re-authenticate user (required by Firebase)
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(_newPasswordController.text);
      }

      // 2. Update display name in FirebaseAuth
      final newName = _nameController.text.trim();

      if (newName.isNotEmpty && user.displayName != newName) {
        await user.updateDisplayName(newName);
      }

      // 3. Save updated data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'name': newName,
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Settings saved!'),
        ),
      );

      // Clear password fields after update
      _currentPasswordController.clear();
      _newPasswordController.clear();

    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text(e.message ?? 'Failed to update profile'),
        ),
      );

    } catch (e) {
      // Handle general errors
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text('An error occurred: $e'),
        ),
      );

    } finally {
      // Stop loading indicator
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build UI ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(title: const Text('Settings')), // App bar

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), // Page padding

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Personal Information Section ───────────────────────
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Name input field
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

            // ── Change Password Section ───────────────────────────
            const Text(
              'Change Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'To change your password, provide your current password.',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),

            const SizedBox(height: 16),

            // Current password field
            TextField(
              controller: _currentPasswordController,
              obscureText: true, // Hide password
              decoration: const InputDecoration(
                labelText: 'Current Password',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            const SizedBox(height: 12),

            // New password field
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

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile, // Disable if loading

                child: _isLoading
                    // Show loader if processing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    // Otherwise show text
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
