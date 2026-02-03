import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  final List<Map<String, String>> categoryList = [
    {"title": "New", "img": "https://images.unsplash.com/photo-1523381210434-271e8be1f52b"},
    {"title": "Clothes", "img": "https://images.unsplash.com/photo-1525507119028-ed4c629a60a3"},
    {"title": "Shoes", "img": "https://images.unsplash.com/photo-1542291026-7eec264c27ff"},
    {"title": "Accessories", "img": "https://images.unsplash.com/photo-1523275335684-37898b6baf30"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: Row(
              children: [
                Expanded(child: Center(child: Text(categoryList[index]['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  child: Image.network(categoryList[index]['img']!, width: 150, fit: BoxFit.cover),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
