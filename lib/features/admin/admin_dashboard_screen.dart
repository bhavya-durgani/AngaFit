import 'package:flutter/material.dart';  
// Imports Flutter UI components

import '../../core/constants/app_colors.dart';  
// Imports custom colors used in app

import 'manage_products_screen.dart';  
// Screen to manage products

import 'manage_orders_screen.dart';  
// Screen to manage orders

class AdminDashboardScreen extends StatelessWidget {  
  // Main admin dashboard screen

  const AdminDashboardScreen({super.key});  

  @override
  Widget build(BuildContext context) {  
    // Builds UI

    return Scaffold(  
      // Main screen structure

      backgroundColor: AppColors.background,  
      // Set background color

      appBar: AppBar(
        title: const Text(
          'Admin Dashboard', 
          style: TextStyle(color: AppColors.black)
        ),  
        // Title of screen

        centerTitle: true,  
        // Center the title

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),  
          // Back button icon

          onPressed: () => Navigator.pop(context),  
          // Go back to previous screen
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),  
        // Add spacing around content

        child: Column(
          // Vertical layout

          children: [

            const SizedBox(height: 20),  
            // Space at top

            _DashboardCard(
              title: 'Manage Products',  
              // First card title

              icon: Icons.inventory_2,  
              // Icon for products

              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageProductsScreen()
                ),
              ),  
              // Navigate to Manage Products screen
            ),

            const SizedBox(height: 16),  
            // Space between cards

            _DashboardCard(
              title: 'Manage Orders',  
              // Second card title

              icon: Icons.local_shipping,  
              // Icon for orders

              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageOrdersScreen()
                ),
              ),  
              // Navigate to Manage Orders screen
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {  
  // Custom reusable card widget

  final String title;  
  // Card title

  final IconData icon;  
  // Card icon

  final VoidCallback onTap;  
  // Function to execute when tapped

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {  
    // Builds each card UI

    return InkWell(
      onTap: onTap,  
      // Detect tap and call function

      borderRadius: BorderRadius.circular(12),  
      // Rounded tap effect

      child: Container(
        height: 120,  
        // Card height

        decoration: BoxDecoration(
          color: Colors.white,  
          // Card background color

          borderRadius: BorderRadius.circular(12),  
          // Rounded corners

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),  
              // Light shadow effect

              blurRadius: 8,  
              // Soft shadow

              offset: const Offset(0, 4),  
              // Shadow position
            )
          ],
        ),

        child: Row(
          // Horizontal layout inside card

          children: [

            Container(
              width: 100,  
              // Left colored section width

              decoration: const BoxDecoration(
                color: AppColors.primaryRed,  
                // Red background

                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12)
                ),  
                // Rounded only on left side
              ),

              child: Center(
                child: Icon(icon, size: 48, color: Colors.white),  
                // Display icon
              ),
            ),

            Expanded(
              // Take remaining space

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),  
                // Horizontal spacing

                child: Text(
                  title,  
                  // Display title

                  style: const TextStyle(
                    fontSize: 22,  
                    fontWeight: FontWeight.bold,  
                    // Make text bold and large
                  ),
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right, 
              size: 32, 
              color: AppColors.grey
            ),  
            // Arrow icon on right side

            const SizedBox(width: 16),  
            // Right spacing
          ],
        ),
      ),
    );
  }
}
