import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cached_network_image/cached_network_image.dart'; // For loading images with caching
import '../../../data/dummy_data.dart'; // Product model
import '../../../core/constants/app_colors.dart'; // App colors

// Stateless widget (just displays product info)
class ProductCard extends StatelessWidget {

  final Product product; // Product data (name, price, image, etc.)
  final VoidCallback onTap; // Function to run when card is tapped

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      // When user taps the card
      onTap: onTap,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // IMAGE SECTION WITH HEART ICON
          Stack(
            children: [

              // Rounded image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),

                child: CachedNetworkImage(
                  imageUrl: product.imageUrl, // Image URL

                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover, // Fill container properly

                  // Placeholder while image loads
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                ),
              ),

              // Favorite (heart) icon at top-right
              const Positioned(
                top: 8,
                right: 8,

                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,

                  child: Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: Colors.grey
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // BRAND NAME
          Text(
            product.brand,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11
            )
          ),

          // PRODUCT NAME
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
            maxLines: 1, // Limit to 1 line
          ),

          // PRICE
          Text(
            "₹${product.price.toStringAsFixed(0)}",
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}
