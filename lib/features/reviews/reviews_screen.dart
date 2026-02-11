import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rating & Reviews")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rating & Reviews", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Column(children: [Text("4.3", style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold)), Text("23 ratings", style: TextStyle(color: AppColors.grey, fontSize: 12))]),
                const SizedBox(width: 32),
                Expanded(child: Column(children: [5, 4, 3, 2, 1].map((i) => _ratingBar(i)).toList())),
              ],
            ),
            const SizedBox(height: 32),
            const Text("8 reviews", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _reviewItem("Helene Moore", "The dress is great! Very classy and comfortable. It fits perfectly!"),
          ],
        ),
      ),
    );
  }

  Widget _ratingBar(int star) {
    return Row(
      children: [
        Text("$star"), const SizedBox(width: 4),
        const Icon(Icons.star, color: Colors.amber, size: 12),
        const SizedBox(width: 8),
        Expanded(child: LinearProgressIndicator(value: star / 5, color: AppColors.primaryRed, backgroundColor: Colors.grey.shade200)),
      ],
    );
  }

  Widget _reviewItem(String name, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Row(children: [Icon(Icons.star, color: Colors.amber, size: 14), Icon(Icons.star, color: Colors.amber, size: 14), Icon(Icons.star, color: Colors.amber, size: 14)]),
        const SizedBox(height: 8),
        Text(text),
        const Divider(height: 32),
      ],
    );
  }
}
