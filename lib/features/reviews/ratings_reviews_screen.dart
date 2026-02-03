import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RatingsReviewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rating&Reviews"), leading: const Icon(Icons.chevron_left)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rating&Reviews", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildRatingSummary(),
            const SizedBox(height: 32),
            const Text("8 reviews", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildReviewItem(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Write a review", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        const Column(
          children: [
            Text("4.3", style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
            Text("23 ratings", style: TextStyle(color: AppColors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((i) => _buildRatingBar(i)).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildRatingBar(int star) {
    return Row(
      children: [
        ...List.generate(star, (_) => const Icon(Icons.star, color: Colors.amber, size: 12)),
        const Spacer(),
        Container(height: 8, width: 100, decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(10))),
      ],
    );
  }

  Widget _buildReviewItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Helene Moore", style: TextStyle(fontWeight: FontWeight.bold)),
        const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 14),
            Icon(Icons.star, color: Colors.amber, size: 14),
            Icon(Icons.star, color: Colors.amber, size: 14),
            Spacer(),
            Text("June 5, 2019", style: TextStyle(color: AppColors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 10),
        const Text("The dress is great! Very classy and comfortable. It fits perfectly! I'm 5'7\" and 130 pounds. I am a 34B chest. This dress would be too long for those who are shorter but could be hemmed."),
      ],
    );
  }
}
