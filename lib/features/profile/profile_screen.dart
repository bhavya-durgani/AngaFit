import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('profile.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      await DatabaseService().updateProfilePhoto(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
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

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null
                            ? const Icon(Icons.person,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: uid != null
                              ? () => _pickAndUploadImage(uid)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    data?['name'] ?? "User",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    data?['email'] ?? "",
                    style: const TextStyle(color: AppColors.grey),
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
