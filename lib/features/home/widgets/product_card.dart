import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/dummy_data.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, size: 18, color: AppColors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) => Icon(Icons.star, color: index < 4 ? Colors.amber : Colors.grey, size: 14)),
          ),
          Text(product.brand, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(product.price, style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
