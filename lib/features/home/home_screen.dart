import 'package:flutter/material.dart';
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
            // Fashion Sale Banner with Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: "https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=2070&auto=format&fit=crop",
                  height: 550,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Container(
                  height: 550,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 40,
                  left: 20,
                  child: Text(
                    "Fashion\nsale",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("New Arrivals", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16
                ),
                itemCount: appProducts.length,
                itemBuilder: (context, index) {
                  final product = appProducts[index];
                  return ProductCard(
                      product: product,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))
                      )
                  );
                }
            )
          ],
        ),
      ),
    );
  }
}
