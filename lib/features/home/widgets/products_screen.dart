import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://images.unsplash.com/photo-1539109136881-3be0616acf4b',
                height: 184, width: 150, fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border, size: 16, color: AppColors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 14),
            Icon(Icons.star, color: Colors.amber, size: 14),
            Icon(Icons.star, color: Colors.amber, size: 14),
            Text(" (3)", style: TextStyle(color: AppColors.grey, fontSize: 10)),
          ],
        ),
        const Text("Mango", style: TextStyle(color: AppColors.grey, fontSize: 11)),
        const Text("T-Shirt Spanish", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const Text("USD 9.00", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
