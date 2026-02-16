import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/dummy_data.dart';
import '../../../core/constants/app_colors.dart';

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
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 180, width: double.infinity, fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                ),
              ),
              const Positioned(
                top: 8, right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(product.brand, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
          Text("₹${product.price.toStringAsFixed(0)}", style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
