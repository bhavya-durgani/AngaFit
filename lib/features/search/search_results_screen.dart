import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../home/widgets/product_card.dart';
import '../product_details/product_details_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(query),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(Icons.filter_list, size: 20), Text(" Filters")]),
                Row(children: [Icon(Icons.swap_vert, size: 20), Text(" Price: low to high")]),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
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
}
