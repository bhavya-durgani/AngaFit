import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';
import 'shipping_addresses_screen.dart';
import '../checkout/payment_methods_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("My profile", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            // User Information from Firestore
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!.data() as Map<String, dynamic>?;

                return ListTile(
                  leading: const CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cfdcb5ab")
                  ),
                  title: Text(data?['name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(data?['email'] ?? "Email not found"),
                );
              },
            ),

            const SizedBox(height: 30),

            // Navigation Options
            _profileTile(context, "My orders", "Already have 12 orders", const OrdersScreen()),
            _profileTile(context, "Shipping addresses", "3 addresses", const ShippingAddressesScreen()),
            _profileTile(context, "Payment methods", "Visa **34", const PaymentMethodsScreen()),
            _profileTile(context, "Settings", "Notifications, password", const SettingsScreen()),

            const SizedBox(height: 40),

            // Sign Out
            Center(
              child: TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false
                    );
                  }
                },
                child: const Text("SIGN OUT", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(BuildContext context, String title, String subtitle, Widget target) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      ),
    );
  }
}
