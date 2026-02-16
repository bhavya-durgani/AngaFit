import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../product_details/product_details_screen.dart';
import '../../data/dummy_data.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Favorites"), centerTitle: true),
      body: user == null
          ? const Center(child: Text("Please login to see favorites"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading favorites"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No favorites yet!"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              // Convert back to Product object for the details screen
              final product = Product(
                name: data['name'],
                brand: data['brand'],
                price: (data['price'] ?? 0).toDouble(),
                imageUrl: data['imageUrl'],
                description: data['description'] ?? "",
                composition: data['composition'] ?? "",
                care: data['care'] ?? "",
              );

              return _buildFavoriteItem(context, docs[index].id, product, user.uid);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, String docId, Product p, String uid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(p.brand, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey),
          onPressed: () => FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('favorites')
              .doc(docId)
              .delete(),
        ),
      ),
    );
  }
}
