import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Header Title
            const Text(
              "My profile",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 24),

            // User Info Section
            const Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    "https://images.unsplash.com/photo-1535713875002-d1d0cfdcb5ab",
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Matilda Brown",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      "matildabrown@mail.com",
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),

            // Profile Options List
            _profileTile(
              context,
              "My orders",
              "Already have 12 orders",
              const OrdersScreen(),
            ),
            _profileTile(
              context,
              "Shipping addresses",
              "3 addresses",
              null, // Add target screen later
            ),
            _profileTile(
              context,
              "Payment methods",
              "Visa **34",
              null,
            ),
            _profileTile(
              context,
              "My reviews",
              "Reviews for 4 items",
              null,
            ),
            _profileTile(
              context,
              "Settings",
              "Notifications, password",
              const SettingsScreen(),
            ),

            const SizedBox(height: 40),

            // Logout Button
            Center(
              child: TextButton(
                onPressed: () {
                  // Logic to clear session and go to Login
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(
      BuildContext context,
      String title,
      String subtitle,
      Widget? target,
      ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: ListTile(
        onTap: () {
          if (target != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => target),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title coming soon!")),
            );
          }
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.grey,
        ),
      ),
    );
  }
}
