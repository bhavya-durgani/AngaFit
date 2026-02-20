import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../data/services/database_service.dart';
import '../ar_view/ar_video_training_screen.dart'; // REDIRECT TO TRAINING FIRST
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
  int quantity = 1;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('favorites').doc(widget.product.name).get();
    if (mounted) setState(() => isFavorite = doc.exists);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.brand),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  height: 400, width: double.infinity, fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                ),
                Positioned(
                  top: 20, right: 16,
                  child: GestureDetector(
                    onTap: () async {
                      await DatabaseService().toggleFavorite(widget.product);
                      setState(() => isFavorite = !isFavorite);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : AppColors.grey, size: 28),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.product.brand, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(widget.product.name, style: const TextStyle(color: AppColors.grey, fontSize: 16)),
                        ],
                      ),
                      // RED TRY ON BUTTON - NOW REDIRECTS TO TRAINING
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ARVideoTrainingScreen(modelName: widget.product.name)
                            )
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(20)),
                          child: const Row(children: [
                            Icon(Icons.videocam, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text("Try On", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("₹${widget.product.price.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewsScreen())),
                    child: const Row(children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star_half, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text("(12 ratings)")
                    ]),
                  ),
                  const SizedBox(height: 24),
                  const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.availableSizes.length,
                      itemBuilder: (context, index) => _buildSizeChip(widget.product.availableSizes[index]),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildExpandableSection("Description", widget.product.description),
                  _buildExpandableSection("Composition", widget.product.composition),
                  _buildExpandableSection("Care Instructions", widget.product.care),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await DatabaseService().addToCart(widget.product, selectedSize, quantity);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Bag!")));
                          },
                          child: const Text("ADD TO BAG"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CheckoutScreen(total: widget.product.price, count: 1))
                          ),
                          child: const Text("BUY NOW"),
                        ),
                      ),
                    ],
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

  Widget _buildSizeChip(String size) {
    bool isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 50, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.primaryRed : Colors.grey.shade300)
        ),
        child: Center(child: Text(size, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildExpandableSection(String title, String content) {
    return ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [Padding(padding: const EdgeInsets.all(16), child: Text(content))],
        tilePadding: EdgeInsets.zero
    );
  }
}
