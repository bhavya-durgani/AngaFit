import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Sort by", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _sortOption("Popular", false),
          _sortOption("Newest", false),
          _sortOption("Customer review", false),
          _sortOption("Price: lowest to high", true),
          _sortOption("Price: highest to low", false),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sortOption(String title, bool isSelected) {
    return Container(
      width: double.infinity,
      color: isSelected ? AppColors.primaryRed : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Colors.white : AppColors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
