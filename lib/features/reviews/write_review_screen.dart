import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WriteReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Write a review")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("What is your rate?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 40, color: AppColors.grey),
                Icon(Icons.star_border, size: 40, color: AppColors.grey),
                Icon(Icons.star_border, size: 40, color: AppColors.grey),
                Icon(Icons.star_border, size: 40, color: AppColors.grey),
                Icon(Icons.star_border, size: 40, color: AppColors.grey),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Please share your opinion about the product", textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 6,
              decoration: InputDecoration(hintText: "Your review", filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 32),
            _buildPhotoUploader(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("SEND REVIEW", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploader() {
    return Row(
      children: [
        Container(
          width: 104, height: 104,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: AppColors.primaryRed), Text("Add photo", style: TextStyle(fontSize: 11))]),
        )
      ],
    );
  }
}
