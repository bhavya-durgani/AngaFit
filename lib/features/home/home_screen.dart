import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/dummy_data.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: "https://images.unsplash.com/photo-1441986300917-64674bd600d8",
                  height: 500, width: double.infinity, fit: BoxFit.cover,
                ),
                Container(
                  height: 500, width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 30, left: 16,
                  child: Text("Fashion Sale", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(alignment: Alignment.centerLeft, child: Text("New Arrivals", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            ),

            // LIVE DATABASE STREAM
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("No products in database yet."),
                  ));
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.6, mainAxisSpacing: 16, crossAxisSpacing: 16,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final product = Product.fromFirestore(docs[index]);
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
