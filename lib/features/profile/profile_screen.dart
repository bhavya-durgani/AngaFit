import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/app_colors.dart';
import '../../data/services/database_service.dart';
import '../admin/admin_login_screen.dart';
import '../auth/login_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';
import 'shipping_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(String uid) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      // 1. Read bytes from picker
      final bytes = await image.readAsBytes();
      
      // 2. Decode and Resize to keep Base64 string small (<1MB Firestore limit)
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final resized = img.copyResize(decoded, width: 150, height: 150);
        
        // 3. Convert to Base64 String
        final pngBytes = img.encodePng(resized);
        final base64String = base64Encode(pngBytes);
        
        // 4. Save directly to Firestore (Bypassing Firebase Storage)
        await DatabaseService().updateProfilePhoto("data:image/png;base64,$base64String");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile update failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // Screen Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "My profile",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // USER INFO SECTION
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final imageUrl = data?['profileImageUrl'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: imageUrl != null && imageUrl.toString().isNotEmpty
                                ? (imageUrl.toString().startsWith('http')
                                    ? NetworkImage(imageUrl)
                                    : MemoryImage(base64Decode(imageUrl.toString().split(',').last))) as ImageProvider
                                : null,
                            child: imageUrl == null || imageUrl.toString().isEmpty
                                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                : null,
                          ),
                          if (_isUploading)
                            const Positioned.fill(
                              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryRed),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: uid != null && !_isUploading
                                  ? () => _pickAndUploadImage(uid)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data?['name'] ?? "User",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? "",
                              style: const TextStyle(color: AppColors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // NAVIGATION LIST
            _profileTile(
              context,
              "My orders",
              "View your order history and status",
              const OrdersScreen(),
            ),
            _profileTile(
              context,
              "Shipping addresses",
              "Manage your delivery locations",
              const ShippingAddressesScreen(),
            ),
            _profileTile(
              context,
              "Settings",
              "Notifications, password, and privacy",
              const SettingsScreen(),
            ),
            _profileTile(
              context,
              "Admin Panel",
              "Manage products and orders (Authorized personnel only)",
              const AdminLoginScreen(),
              isHighlight: true,
            ),

            const SizedBox(height: 40),

            // SIGN OUT BUTTON
            Center(
              child: TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  "SIGN OUT",
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(
    BuildContext context,
    String title,
    String subtitle,
    Widget target, {
    bool isHighlight = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => target),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primaryRed : AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.grey, fontSize: 11),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isHighlight ? AppColors.primaryRed : AppColors.grey,
        ),
      ),
    );
  }
}
