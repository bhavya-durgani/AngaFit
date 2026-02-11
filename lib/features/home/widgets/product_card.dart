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
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              // FAVORITES ICON (Heart)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Brand Name
          Text(
            product.brand,
            style: const TextStyle(color: AppColors.grey, fontSize: 11),
          ),
          const SizedBox(height: 2),
          // Product Name
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Price (Displays Rupee symbol from dummy_data)
          Text(
            product.price,
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
