import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../home/widgets/product_card.dart';
import '../product_details/product_details_screen.dart';
import '../search/search_screen.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/sort_bottom_sheet.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String activeCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Shop"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // CENTER ALIGNED CATEGORY BAR
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: appCategories.map((category) {
                bool isSelected = activeCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => activeCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.black : AppColors.grey,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 3,
                            width: 20,
                            color: AppColors.primaryRed,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _barItem(Icons.filter_list, "Filters", () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const FilterBottomSheet())),
                _barItem(Icons.swap_vert, "Price: low to high", () => showModalBottomSheet(context: context, builder: (_) => const SortBottomSheet())),
                const Icon(Icons.view_module, color: AppColors.black),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: appProducts.length,
              itemBuilder: (context, index) {
                final product = appProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _barItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
