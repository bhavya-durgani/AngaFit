import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../home/widgets/product_card.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/filter_bottom_sheet.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String activeCategory = "All";
  String sortMethod = "Newest"; // Current sort state
  RangeValues currentRange = const RangeValues(0, 10000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Shop"), centerTitle: true),
      body: Column(
        children: [
          _buildCategoryBar(),
          // ACTION BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _barBtn(Icons.filter_list, "Filters", () async {
                  final result = await showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => FilterBottomSheet(initialRange: currentRange));
                  if (result != null) setState(() => currentRange = result);
                }),
                // SORT BUTTON: Now updates the state
                _barBtn(Icons.swap_vert, sortMethod, () async {
                  final result = await showModalBottomSheet(
                      context: context,
                      builder: (_) => const SortBottomSheet()
                  );
                  // If user selected a new method, update UI
                  if (result != null) {
                    setState(() {
                      sortMethod = result;
                    });
                  }
                }),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // 1. Convert docs to a List so we can sort them
                List<DocumentSnapshot> items = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final price = (data['price'] ?? 0).toDouble();
                  final cat = data['category'] ?? "All";

                  bool matchCat = activeCategory == "All" || cat == activeCategory;
                  bool matchPrice = price >= currentRange.start && price <= currentRange.end;
                  return matchCat && matchPrice;
                }).toList();

                // 2. APPLY SORTING LOGIC
                if (sortMethod == "Price: low to high") {
                  items.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
                } else if (sortMethod == "Price: high to low") {
                  items.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
                }
                // Note: 'Newest' uses Firestore's default order or you can add a 'createdAt' field

                if (items.isEmpty) return const Center(child: Text("No products found"));

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.6, mainAxisSpacing: 16, crossAxisSpacing: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = Product.fromFirestore(items[index]);
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

  Widget _buildCategoryBar() {
    return Container(
      height: 50, color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: appCategories.map((cat) => GestureDetector(
          onTap: () => setState(() => activeCategory = cat),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text(cat, style: TextStyle(fontWeight: activeCategory == cat ? FontWeight.bold : FontWeight.normal))),
        )).toList(),
      ),
    );
  }

  Widget _barBtn(IconData i, String l, VoidCallback t) => InkWell(onTap: t, child: Row(children: [Icon(i, size: 20), const SizedBox(width: 8), Text(l, style: const TextStyle(fontSize: 12))]));
}
