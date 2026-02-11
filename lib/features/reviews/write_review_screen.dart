import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Write a review")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("What is your rate?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Star Rating Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: index < _rating ? Colors.amber : AppColors.grey,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),

            const SizedBox(height: 32),
            const Text(
              "Please share your opinion about the product",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),

            // Review Text Field
            const TextField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Your review",
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Photo Uploader Placeholder
            Row(
              children: [
                _buildPhotoBox(Icons.camera_alt, "Add photo"),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: AppColors.success, content: Text("Review sent!")),
                  );
                },
                child: const Text("SEND REVIEW"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox(IconData icon, String label) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryRed, size: 30),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
