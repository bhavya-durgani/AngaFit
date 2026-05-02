import 'package:flutter/material.dart'; // Imports Flutter UI framework
import '../../core/constants/app_colors.dart'; // Imports custom color constants

// Stateless widget because data is static (no dynamic state changes)
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rating & Reviews")), // Top app bar

      // Scrollable body so content doesn't overflow on smaller screens
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), // Padding around content

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to left
          children: [

            // Title text
            const Text(
              "Rating & Reviews", 
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 24), // Space

            // Row for rating summary
            Row(
              children: [

                // Left side: Overall rating + total ratings
                const Column(
                  children: [
                    Text(
                      "4.3", 
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      "23 ratings", 
                      style: TextStyle(color: AppColors.grey, fontSize: 12)
                    )
                  ]
                ),

                const SizedBox(width: 32), // Space between sections

                // Right side: Rating bars (5 to 1 stars)
                Expanded(
                  child: Column(
                    children: [
                      5, 4, 3, 2, 1 // List of star levels
                    ].map((i) => _ratingBar(i)).toList() // Convert each to UI row
                  )
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Reviews count title
            const Text(
              "8 reviews", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 16),

            // Single review item (hardcoded)
            _reviewItem(
              "Helene Moore", 
              "The dress is great! Very classy and comfortable. It fits perfectly!"
            ),
          ],
        ),
      ),
    );
  }

  // Widget to show rating bar for each star level
  Widget _ratingBar(int star) {
    return Row(
      children: [

        // Star number (e.g., 5, 4, 3...)
        Text("$star"), 

        const SizedBox(width: 4),

        // Star icon
        const Icon(Icons.star, color: Colors.amber, size: 12),

        const SizedBox(width: 8),

        // Progress bar showing rating distribution
        Expanded(
          child: LinearProgressIndicator(
            value: star / 5, // Progress (example logic, not real data)
            color: AppColors.primaryRed, // Filled color
            backgroundColor: Colors.grey.shade200, // Background color
          )
        ),
      ],
    );
  }

  // Widget to display a single review
  Widget _reviewItem(String name, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Reviewer name
        Text(
          name, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),

        // Static star rating (3 stars shown)
        const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 14),
            Icon(Icons.star, color: Colors.amber, size: 14),
            Icon(Icons.star, color: Colors.amber, size: 14)
          ]
        ),

        const SizedBox(height: 8),

        // Review text
        Text(text),

        const Divider(height: 32), // Divider line between reviews
      ],
    );
  }
}
