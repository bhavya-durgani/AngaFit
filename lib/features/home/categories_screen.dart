import 'package:flutter/material.dart';
import 'sub_categories_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {"name": "Women", "image": "https://images.unsplash.com/photo-1525507119028-ed4c629a60a3"},
    {"name": "Men", "image": "https://images.unsplash.com/photo-1490578474895-699cd4e2cf59"},
    {"name": "Kids", "image": "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubCategoriesScreen(categoryName: categories[index]['name']!))),
            child: Container(
              height: 100, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Expanded(child: Center(child: Text(categories[index]['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                ClipRRect(borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)), child: Image.network(categories[index]['image']!, width: 150, fit: BoxFit.cover))
              ]),
            ),
          );
        },
      ),
    );
  }
}
