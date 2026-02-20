import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../catalog/product_list_screen.dart';

class SubCategoriesScreen extends StatelessWidget {
  final String categoryName;
  const SubCategoriesScreen({super.key, required this.categoryName});

  final List<String> subCategories = [
    "Tops", "Shirts & Blouses", "Cardigans & Sweaters",
    "Knitwear", "Blazers", "Outerwear", "Pants", "Jeans"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // View All Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListScreen())
                ),
                child: const Text("VIEW ALL ITEMS"),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Choose category", style: TextStyle(color: AppColors.grey))
            ),
          ),
          // Sub-Category List
          Expanded(
            child: ListView.separated(
              itemCount: subCategories.length,
              separatorBuilder: (context, index) => const Divider(indent: 16),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      subCategories[index],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductListScreen())
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
