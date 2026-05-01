import 'package:flutter/material.dart'; // Flutter UI
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import '../../core/constants/app_colors.dart'; // App colors
import '../../data/dummy_data.dart'; // Dummy categories data
import '../home/widgets/product_card.dart'; // Product UI card
import '../product_details/product_details_screen.dart'; // Product details screen
import 'widgets/sort_bottom_sheet.dart'; // Sort UI
import 'widgets/filter_bottom_sheet.dart'; // Filter UI

// Stateful screen for product listing
class ProductListScreen extends StatefulWidget {

  final String? searchQuery; // Initial search text (optional)

  const ProductListScreen({super.key, this.searchQuery});

  @override 
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  String activeCategory = "All"; // Selected category
  String sortMethod = "Newest"; // Selected sorting method

  RangeValues currentRange = const RangeValues(0, 10000); // Price range
  String? selectedSize; // Selected size filter
  String? selectedColor; // Selected color filter

  late TextEditingController _searchController; // Search input controller

  @override
  void initState() {
    super.initState();

    // Initialize search box with passed query (if any)
    _searchController = TextEditingController(
      text: widget.searchQuery ?? ''
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("Shop"),
        centerTitle: true
      ),

      body: Column(
        children: [

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

            child: TextField(
              controller: _searchController, // Attach controller

              // When user types → rebuild UI
              onChanged: (val) => setState(() {}),

              decoration: InputDecoration(
                hintText: "Search products or brands...", // Placeholder

                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.grey
                ),

                // Show clear button if text exists
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.grey),

                      onPressed: () {
                        _searchController.clear(); // Clear text
                        setState(() {}); // Refresh UI
                      }
                    ) 
                  : null,

                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(vertical: 0),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          // CATEGORY BAR
          _buildCategoryBar(),

          // ACTION BAR (Filter + Sort)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                // FILTER BUTTON
                _barBtn(Icons.filter_list, "Filters", () async {

                  // Open filter bottom sheet
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,

                    builder: (_) => FilterBottomSheet(
                      initialRange: currentRange,
                      initialSize: selectedSize,
                      initialColor: selectedColor,
                    )
                  );

                  // Apply filters if returned
                  if (result != null && result is Map) {
                    setState(() {
                      currentRange = result['range'] ?? const RangeValues(0, 10000);
                      selectedSize = result['size'];
                      selectedColor = result['color'];
                    });
                  }
                }),

                // SORT BUTTON
                _barBtn(Icons.swap_vert, sortMethod, () async {

                  // Open sort bottom sheet
                  final result = await showModalBottomSheet(
                    context: context,
                    builder: (_) => const SortBottomSheet()
                  );

                  // Update sorting method
                  if (result != null) {
                    setState(() {
                      sortMethod = result;
                    });
                  }
                }),
              ],
            ),
          ),

          // PRODUCT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              // Listen to Firestore products
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),

              builder: (context, snapshot) {

                // If error occurs
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                          const SizedBox(height: 16),

                          const Text(
                            'Failed to load products',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 8),

                          // Show actual error
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show loading
                if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // FILTER LOGIC
                List<DocumentSnapshot> items = snapshot.data!.docs.where((doc) {

                  final data = doc.data() as Map<String, dynamic>;

                  final price = (data['price'] ?? 0).toDouble();
                  final cat = data['category'] ?? 'All';
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final brand = (data['brand'] ?? '').toString().toLowerCase();

                  final List<dynamic> sizes = data['availableSizes'] ?? [];
                  final List<dynamic> colors = data['availableColors'] ?? [];

                  // Category filter
                  bool matchCat = activeCategory == 'All' || cat == activeCategory;

                  // Price filter
                  bool matchPrice = price >= currentRange.start && price <= currentRange.end;

                  // Search filter
                  final query = _searchController.text.trim().toLowerCase();
                  bool matchSearch = query.isEmpty ||
                      name.contains(query) ||
                      brand.contains(query);

                  // Size filter
                  bool matchSize = selectedSize == null || sizes.contains(selectedSize);

                  // Color filter
                  bool matchColor = selectedColor == null ||
                      colors.any((c) => c.toString().toLowerCase() == selectedColor!.toLowerCase());

                  return matchCat && matchPrice && matchSearch && matchSize && matchColor;
                }).toList();

                // SORTING LOGIC
                if (sortMethod == "Price: low to high") {
                  items.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
                } else if (sortMethod == "Price: high to low") {
                  items.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
                }

                // If no items found
                if (items.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                // GRID VIEW
                return GridView.builder(
                  padding: const EdgeInsets.all(16),

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns
                    childAspectRatio: 0.6,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16
                  ),

                  itemCount: items.length,

                  itemBuilder: (context, index) {

                    // Convert Firestore doc to Product model
                    final product = Product.fromFirestore(items[index]);

                    return ProductCard(

                      product: product,

                      // Open product details screen
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: product)
                        )
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // CATEGORY BAR UI
  Widget _buildCategoryBar() {
    return Container(
      height: 50,
      color: Colors.white,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: appCategories.map((cat) => GestureDetector(

          // Change category
          onTap: () => setState(() => activeCategory = cat),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),

            child: Text(
              cat,
              style: TextStyle(
                fontWeight: activeCategory == cat
                    ? FontWeight.bold
                    : FontWeight.normal
              )
            ),
          ),
        )).toList(),
      ),
    );
  }

  // Button for filter/sort
  Widget _barBtn(IconData i, String l, VoidCallback t) => InkWell(
    onTap: t,

    child: Row(
      children: [
        Icon(i, size: 20),
        const SizedBox(width: 8),
        Text(l, style: const TextStyle(fontSize: 12))
      ]
    )
  );
}
