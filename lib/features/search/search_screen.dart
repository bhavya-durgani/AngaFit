import 'package:flutter/material.dart';
import '../visual_search/visual_search_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search for items...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen())),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text("Popular Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const ListTile(title: Text("Summer Collection"), trailing: Icon(Icons.chevron_right)),
            const ListTile(title: Text("AR Ready Outfits"), trailing: Icon(Icons.chevron_right)),
            const ListTile(title: Text("Men's Formal"), trailing: Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }
}
