import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../product_details/product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Favorites"), centerTitle: true),
      body: uid == null
          ? const Center(child: Text("Please login to see favorites"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No favorites added yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              // Convert back to Product object
              final product = Product(
                name: data['name'],
                brand: data['brand'],
                price: (data['price'] ?? 0).toDouble(),
                imageUrl: data['imageUrl'],
                description: data['description'] ?? "",
                composition: data['composition'] ?? "",
                care: data['care'] ?? "",
                availableSizes: List<String>.from(data['availableSizes'] ?? []),
                availableColors: List<String>.from(data['availableColors'] ?? []),
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                  ),
                  leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(product.brand),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => docs[index].reference.delete(), // Remove from favorites
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
