import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _DashboardCard(
              title: 'Manage Products',
              icon: Icons.inventory_2,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              title: 'Manage Orders',
              icon: Icons.local_shipping,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(icon, size: 48, color: Colors.white),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 32, color: AppColors.grey),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
