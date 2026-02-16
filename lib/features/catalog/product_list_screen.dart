import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../home/widgets/product_card.dart';
import '../product_details/product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? searchQuery; // Optional query from the Search tab
  const ProductListScreen({super.key, this.searchQuery});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String activeCategory = "All";
  String currentSearch = "";

  @override
  void initState() {
    super.initState();
    currentSearch = widget.searchQuery ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Shop"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => currentSearch = val),
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Centered Category Bar
          Container(
            height: 50, width: double.infinity, color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: appCategories.map((category) {
                bool isSelected = activeCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => activeCategory = category),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(category, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.black : AppColors.grey)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // Client-side filtering for Search (Firestore doesn't support easy partial string search)
                final docs = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return name.contains(currentSearch.toLowerCase());
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("No products found"));

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.6, mainAxisSpacing: 16, crossAxisSpacing: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final product = Product.fromFirestore(docs[index]);
                    return ProductCard(product: product, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    if (activeCategory == "All") {
      return FirebaseFirestore.instance.collection('products').snapshots();
    } else {
      return FirebaseFirestore.instance.collection('products').where('category', isEqualTo: activeCategory).snapshots();
    }
  }
}
