import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:cached_network_image/cached_network_image.dart'; // For optimized image loading
import '../../data/dummy_data.dart'; // Product model
import '../product_details/product_details_screen.dart'; // Product details screen
import 'widgets/product_card.dart'; // Reusable product card widget

// Stateless widget (UI depends on stream, not internal state)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Whole page scrollable
      body: SingleChildScrollView(

        child: Column(
          children: [

            // =======================
            // TOP BANNER SECTION
            // =======================
            Stack(
              children: [

                // Background image
                CachedNetworkImage(
                  imageUrl: "https://images.unsplash.com/photo-1441986300917-64674bd600d8",
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover, // Fill space properly
                ),

                // Dark gradient overlay on image
                Container(
                  height: 500,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,

                      // Transparent at top → dark at bottom
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7)
                      ],
                    ),
                  ),
                ),

                // Text on banner
                const Positioned(
                  bottom: 30,
                  left: 16,

                  child: Text(
                    "Fashion Sale",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ],
            ),

            // =======================
            // SECTION TITLE
            // =======================
            const Padding(
              padding: EdgeInsets.all(16),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "New Arrivals",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),

            // =======================
            // FIRESTORE DATA STREAM
            // =======================
            StreamBuilder<QuerySnapshot>(

              // Listen to 'products' collection in Firestore
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),

              builder: (context, snapshot) {

                // If error occurs
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          const Icon(
                            Icons.cloud_off,
                            size: 56,
                            color: Colors.red
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Failed to load products',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            )
                          ),

                          const SizedBox(height: 8),

                          // Show actual error message
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11
                            )
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show loading while fetching data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Get all documents (products)
                final docs = snapshot.data!.docs;

                // If no products found
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No products in database yet."),
                    )
                  );
                }

                // =======================
                // GRID OF PRODUCTS
                // =======================
                return GridView.builder(

                  shrinkWrap: true, // Take only needed space
                  physics: const NeverScrollableScrollPhysics(), // Disable inner scroll

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: 2, // 2 items per row
                    childAspectRatio: 0.6, // Width/height ratio
                    mainAxisSpacing: 16, // Vertical spacing
                    crossAxisSpacing: 16, // Horizontal spacing
                  ),

                  itemCount: docs.length, // Number of products

                  itemBuilder: (context, index) {

                    // Convert Firestore doc → Product object
                    final product = Product.fromFirestore(docs[index]);

                    return ProductCard(

                      product: product, // Pass product data

                      // When user taps product
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: product)
                        )
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30), // Bottom spacing
          ],
        ),
      ),
    );
  }
}
