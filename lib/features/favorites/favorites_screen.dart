import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../product_details/product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (context, index) {
          final p = appProducts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))),
              leading: Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(p.brand),
              trailing: IconButton(
                icon: const Icon(Icons.shopping_cart, color: Color(0xFFDB3022)),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Bag!"))),
              ),
            ),
          );
        },
      ),
    );
  }
}
