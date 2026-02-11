import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../visual_search/visual_search_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search for clothes...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Popular Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _categoryTile("Trending Now"),
            _categoryTile("Summer Collection"),
            _categoryTile("AR Ready Outfits"),
            _categoryTile("New Arrivals"),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
