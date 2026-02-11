import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../ar_view/ar_try_on_screen.dart';
import '../checkout/checkout_screen.dart';
import '../reviews/reviews_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = "M";
  bool isFavorite = false;
  final List<String> sizes = ["XS", "S", "M", "L", "XL"];
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.name),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            CachedNetworkImage(
              imageUrl: widget.product.imageUrl,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info and Action Column (Heart + Try On)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.product.brand, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(widget.product.name, style: const TextStyle(color: AppColors.grey, fontSize: 16)),
                            const SizedBox(height: 8),
                            // Ratings Redirection
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewsScreen())),
                              child: const Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  Icon(Icons.star_half, color: Colors.amber, size: 18),
                                  SizedBox(width: 4),
                                  Text("(12)", style: TextStyle(color: AppColors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action Column
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => isFavorite = !isFavorite),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : AppColors.grey,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Small Red Try On Button
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ARTryOnScreen())),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.view_in_ar, color: Colors.white, size: 18),
                                  SizedBox(width: 4),
                                  Text("Try On", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(widget.product.price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),

                  const SizedBox(height: 24),
                  const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sizes.length,
                      itemBuilder: (context, index) => _buildSizeChip(sizes[index]),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _circleIcon(Icons.remove, () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text("$quantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _circleIcon(Icons.add, () {
                        setState(() {
                          quantity++;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildExpandableSection("Item Details", widget.product.description),
                  const Divider(),
                  _buildExpandableSection("Composition", widget.product.composition),
                  const Divider(),
                  _buildExpandableSection("Care Instructions", widget.product.care),

                  const SizedBox(height: 32),

                  // Bottom Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Bag!")));
                      },
                      child: const Text("ADD TO CART", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                      child: const Text("BUY NOW"),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildSizeChip(String size) {
    bool isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 50,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primaryRed : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(size, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, String content) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      children: [Padding(padding: const EdgeInsets.all(16), child: Text(content, style: const TextStyle(height: 1.5)))],
      tilePadding: EdgeInsets.zero,
    );
  }
}
