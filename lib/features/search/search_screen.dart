import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../catalog/product_list_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH INPUT FIELD
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(searchQuery: query),
                    ),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: "Search for clothes...",
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Popular Searches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildSearchSuggestion(context, "Evening Dress"),
            _buildSearchSuggestion(context, "Cotton T-Shirt"),
            _buildSearchSuggestion(context, "Wool Pullover"),
            _buildSearchSuggestion(context, "Winter Wear"),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestion(BuildContext context, String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(text, style: const TextStyle(color: Colors.black87)),
      trailing: const Icon(Icons.north_west, size: 18, color: AppColors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductListScreen(searchQuery: text)),
        );
      },
    );
  }
}
