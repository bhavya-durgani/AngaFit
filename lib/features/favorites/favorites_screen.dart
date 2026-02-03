import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Favorites"),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) => _buildFavoriteItem(),
      ),
    );
  }

  Widget _buildFavoriteItem() {
    return Container(
      height: 104,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            child: Image.network('https://images.unsplash.com/photo-1554568218-0f1715e72254', width: 104, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("LIME", style: TextStyle(color: AppColors.grey, fontSize: 11)),
                  const Text("Shirt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text("Color: Blue  Size: L", style: TextStyle(color: AppColors.grey, fontSize: 11)),
                  const Spacer(),
                  const Text("USD 32.00", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.close, color: AppColors.grey, size: 20),
          )
        ],
      ),
    );
  }
}
