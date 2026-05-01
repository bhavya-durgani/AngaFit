import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import '../../data/dummy_data.dart'; // Product model (dummy data structure)
import '../product_details/product_details_screen.dart'; // Product details screen

// Stateless widget (no changing state inside this screen)
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {

    // Get current logged-in user's ID
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(

      // Top app bar
      appBar: AppBar(
        title: const Text("Favorites") // Screen title
      ),

      // BODY
      body: StreamBuilder<QuerySnapshot>(

        // Listen to user's favorites collection in Firestore
        stream: FirebaseFirestore.instance
            .collection('users') // users collection
            .doc(uid) // current user
            .collection('favorites') // favorites subcollection
            .snapshots(), // real-time updates

        builder: (context, snapshot) {

          // Show loading while data is coming
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs; // List of favorite items

          return ListView.builder(

            itemCount: docs.length, // Total favorite items

            itemBuilder: (context, index) {

              // Convert Firestore data into Product object
              final product = Product.fromFirestore(docs[index]);

              return ListTile(

                // Product image
                leading: Image.network(
                  product.imageUrl,
                  width: 50
                ),

                // Product name
                title: Text(product.name),

                // When user taps → go to product details screen
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailsScreen(product: product)
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
