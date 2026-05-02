import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:cached_network_image/cached_network_image.dart'; // For optimized network image loading with caching
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication (for user ID)
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import '../../core/constants/app_colors.dart'; // Custom app colors
import '../../data/dummy_data.dart'; // Product model (dummy data structure)
import '../../data/services/database_service.dart'; // Service for DB operations (favorites, cart)
import '../ar_view/ar_try_on_screen.dart'; // AR try-on screen (not used here directly)
import '../ar_view/three_sixty_capture_screen.dart'; // 360 capture screen
import '../checkout/checkout_screen.dart'; // Checkout screen
import '../reviews/reviews_screen.dart'; // Reviews screen

// Stateful widget for product details page
class ProductDetailsScreen extends StatefulWidget {
  final Product product; // Product object passed to screen

  const ProductDetailsScreen({super.key, required this.product}); // Constructor

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState(); // Create state
}

// State class
class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = "M"; // Default selected size
  bool isFavorite = false; // Favorite status
  int quantity = 1; // Default quantity
  bool _isAdding = false; // Loading state for add-to-cart button
  final uid = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus(); // Check if product is already in favorites
  }

  // Check favorite status from Firestore
  Future<void> _checkFavoriteStatus() async {
    if (uid == null) return; // If user not logged in, exit

    final doc = await FirebaseFirestore.instance
        .collection('users') // users collection
        .doc(uid) // current user document
        .collection('favorites') // favorites subcollection
        .doc(widget.product.name) // product document (using name as ID)
        .get(); // fetch document

    if (mounted) setState(() => isFavorite = doc.exists); // update UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Screen background color

      appBar: AppBar(
        title: Text(widget.product.brand), // Show brand in app bar
        centerTitle: true,
      ),

      body: SingleChildScrollView( // Scrollable screen
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 1. PRODUCT IMAGE (Floating Heart Icon)
            Stack(
              children: [

                // Product image
                CachedNetworkImage(
                  imageUrl: widget.product.imageUrl, // image URL
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover, // cover entire area
                  placeholder: (context, url) => Container(color: Colors.grey[200]), // placeholder while loading
                ),

                // Favorite (heart) button
                Positioned(
                  top: 20,
                  right: 16,
                  child: GestureDetector(
                    onTap: () async {
                      await DatabaseService().toggleFavorite(widget.product); // toggle in DB
                      setState(() => isFavorite = !isFavorite); // update UI
                    },

                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),

                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border, // filled or outline icon
                        color: isFavorite ? Colors.red : AppColors.grey,
                        size: 28,
                      ),
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

                  // 2. BRAND & 360 TRY ON BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // Brand name
                      Text(
                        widget.product.brand,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),

                      // 360 Try-On Button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThreeSixtyCaptureScreen(
                              product: widget.product, // pass product
                              selectedSize: selectedSize, // selected size
                              garmentImageUrl: widget.product.imageUrl, // image URL
                            ),
                          ),
                        ),

                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRed.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),

                          child: const Row(
                            children: [
                              Icon(Icons.threesixty, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "360° TRY ON",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3. PRODUCT NAME
                  Text(
                    widget.product.name,
                    style: const TextStyle(color: AppColors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  // 4. PRICE
                  Text(
                    "₹${widget.product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 5. REVIEWS
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReviewsScreen()),
                    ),

                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Icon(Icons.star_half, color: Colors.amber, size: 18),
                        SizedBox(width: 4),
                        Text("(12 ratings)", style: TextStyle(color: AppColors.grey, fontSize: 12)),
                        Spacer(),
                        Icon(Icons.chevron_right, color: AppColors.grey),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. SIZE SELECTION
                  const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 45,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.availableSizes.length,

                      itemBuilder: (context, index) =>
                          _buildSizeChip(widget.product.availableSizes[index]), // build each chip
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 7. QUANTITY SELECTION
                  const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      // Decrease quantity
                      _qtyIcon(Icons.remove, () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      }),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "$quantity",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Increase quantity
                      _qtyIcon(Icons.add, () {
                        setState(() {
                          quantity++;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 8. EXPANDABLE SECTIONS
                  _buildExpandableSection("Description", widget.product.description),
                  const Divider(),
                  _buildExpandableSection("Composition", widget.product.composition),
                  const Divider(),
                  _buildExpandableSection("Care Instructions", widget.product.care),

                  const SizedBox(height: 40),

                  // 9. ACTION BUTTONS
                  Row(
                    children: [

                      // ADD TO BAG
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryRed),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),

                          onPressed: _isAdding ? null : () async {
                            setState(() => _isAdding = true); // start loading
                            await DatabaseService().addToCart(widget.product, selectedSize, quantity); // add to cart
                            setState(() => _isAdding = false); // stop loading

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Added to Bag!")),
                            );
                          },

                          child: _isAdding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  "ADD TO BAG",
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // BUY NOW
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final directItem = {
                              'name': widget.product.name,
                              'brand': widget.product.brand,
                              'price': widget.product.price,
                              'imageUrl': widget.product.imageUrl,
                              'size': selectedSize,
                              'quantity': quantity,
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  total: widget.product.price * quantity, // total price
                                  count: quantity,
                                  directItems: [directItem],
                                ),
                              ),
                            );
                          },

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

  // Quantity button widget
  Widget _qtyIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  // Size selection chip
  Widget _buildSizeChip(String size) {
    bool isSelected = selectedSize == size;

    return GestureDetector(
      onTap: () => setState(() => selectedSize = size), // update size

      child: Container(
        width: 50,
        margin: const EdgeInsets.only(right: 12),

        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
          ),
        ),

        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Expandable section (description, care, etc.)
  Widget _buildExpandableSection(String title, String content) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),

      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            content,
            style: const TextStyle(height: 1.5),
          ),
        )
      ],

      tilePadding: EdgeInsets.zero,
    );
  }
}
