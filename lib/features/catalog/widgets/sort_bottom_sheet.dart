import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SortBottomSheet extends StatelessWidget {
  final List<String> options = ["Popular", "Newest", "Customer review", "Price: lowest to high", "Price: highest to low"];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          const Text("Sort by", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...options.map((option) => _buildOption(option, option == "Price: lowest to high")),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(String title, bool isSelected) {
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
