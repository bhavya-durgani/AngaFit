import 'dart:io'; // Provides File handling (not heavily used here but useful for image handling)
import 'dart:convert'; // For Base64 encoding/decoding
import 'package:flutter/foundation.dart'; // Flutter foundation utilities
import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:image_picker/image_picker.dart'; // Pick image from gallery/camera
import 'package:image/image.dart' as img; // Image processing (resize, decode, encode)
import '../../core/constants/app_colors.dart'; // Custom colors
import '../../data/services/database_service.dart'; // Database helper methods
import '../admin/admin_login_screen.dart'; // Admin login screen
import '../auth/login_screen.dart'; // Login screen
import 'orders_screen.dart'; // Orders screen
import 'settings_screen.dart'; // Settings screen
import 'shipping_addresses_screen.dart'; // Shipping address screen

// Stateful widget because we manage uploading state
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false; // Track if image is uploading

  // Function to pick image and upload to Firestore
  Future<void> _pickAndUploadImage(String uid) async {
    final picker = ImagePicker(); // Create image picker instance

    // Open gallery and pick image
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Reduce quality to save size
    );

    if (image == null) return; // If user cancels, exit

    setState(() => _isUploading = true); // Show loading indicator

    try {
      // 1. Read image as bytes
      final bytes = await image.readAsBytes();
      
      // 2. Decode image and resize (to reduce size for Firestore limit)
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final resized = img.copyResize(decoded, width: 150, height: 150);
        
        // 3. Convert resized image to PNG bytes
        final pngBytes = img.encodePng(resized);

        // Convert PNG bytes to Base64 string
        final base64String = base64Encode(pngBytes);
        
        // 4. Save Base64 image directly in Firestore
        await DatabaseService().updateProfilePhoto("data:image/png;base64,$base64String");
      }
    } catch (e) {
      // Show error if upload fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile update failed: $e")),
        );
      }
    } finally {
      // Stop loading indicator
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user ID
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      body: SingleChildScrollView( // Scrollable UI
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // Top spacing

            // Screen Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "My profile",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // USER INFO SECTION (Real-time Firestore data)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users') // Users collection
                  .doc(uid) // Current user document
                  .snapshots(), // Real-time updates

              builder: (context, snapshot) {
                // Convert snapshot data to map
                final data = snapshot.data?.data() as Map<String, dynamic>?;

                // Get profile image URL/Base64
                final imageUrl = data?['profileImageUrl'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Profile Image + Camera Button
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade200,

                            // Decide image source (Network OR Base64 OR null)
                            backgroundImage: imageUrl != null && imageUrl.toString().isNotEmpty
                                ? (imageUrl.toString().startsWith('http')
                                    ? NetworkImage(imageUrl) // If URL
                                    : MemoryImage(base64Decode(imageUrl.toString().split(',').last))) as ImageProvider
                                : null,

                            // Show default icon if no image
                            child: imageUrl == null || imageUrl.toString().isEmpty
                                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                : null,
                          ),

                          // Loading indicator while uploading
                          if (_isUploading)
                            const Positioned.fill(
                              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryRed),
                            ),

                          // Camera button to change image
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: uid != null && !_isUploading
                                  ? () => _pickAndUploadImage(uid) // Pick new image
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

                      // User Name & Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data?['name'] ?? "User", // User name
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? "", // Email
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

            // NAVIGATION OPTIONS
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
              isHighlight: true, // Highlight this option
            ),

            const SizedBox(height: 40),

            // SIGN OUT BUTTON
            Center(
              child: TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); // Logout

                  // Navigate to login screen and clear history
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

  // Reusable tile widget for profile options
  Widget _profileTile(
    BuildContext context,
    String title,
    String subtitle,
    Widget target, {
    bool isHighlight = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))), // Bottom border
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => target), // Navigate to screen
        ),

        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primaryRed : AppColors.black, // Highlight color
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.grey, fontSize: 11),
        ),

        trailing: Icon(
          Icons.chevron_right, // Arrow icon
          color: isHighlight ? AppColors.primaryRed : AppColors.grey,
        ),
      ),
    );
  }
}
