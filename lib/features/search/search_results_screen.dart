import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database package
import '../../core/constants/app_colors.dart'; // Custom app colors
import '../../data/dummy_data.dart'; // Contains Product model + dummy data
import '../home/widgets/product_card.dart'; // UI widget to display a product
import '../product_details/product_details_screen.dart'; // Product details screen

// Stateless because search results are handled via StreamBuilder (no manual state)
class SearchResultsScreen extends StatelessWidget {
  final String query; // Search query passed from previous screen

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      // App bar showing search query
      appBar: AppBar(
        title: Text("Results for '$query'"), 
        centerTitle: true
      ),

      // StreamBuilder listens to real-time Firestore updates
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products') // Access 'products' collection
            .snapshots(), // Real-time data stream

        builder: (context, snapshot) {

          // If data is still loading → show loader
          if (!snapshot.hasData) 
            return const Center(child: CircularProgressIndicator());

          // 🔍 Search logic:
          // Filter products whose name contains the search query
          final docs = snapshot.data!.docs.where((doc) {
            final name = doc['name'].toString().toLowerCase(); // Convert product name to lowercase
            return name.contains(query.toLowerCase()); // Match with query (case-insensitive)
          }).toList();

          // If no matching results found
          if (docs.isEmpty) 
            return const Center(child: Text("No matches found"));

          // Display results in grid layout
          return GridView.builder(
            padding: const EdgeInsets.all(16), // Outer padding

            // Grid layout configuration
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              childAspectRatio: 0.6, // Height/width ratio
              mainAxisSpacing: 16, // Vertical spacing
              crossAxisSpacing: 16, // Horizontal spacing
            ),

            itemCount: docs.length, // Total filtered products

            itemBuilder: (context, index) {

              // Convert Firestore document → Product object
              final product = Product.fromFirestore(docs[index]);

              // Show product card
              return ProductCard(
                product: product,

                // On tap → navigate to product details screen
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product)
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
