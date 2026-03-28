import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../data/services/database_service.dart';
import 'admin_upload_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  void _confirmDelete(Product p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to completely delete "${p.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // If id is empty, fallback to product name (as it was used before)
                final productId = p.id.isNotEmpty ? p.id : p.name;
                await DatabaseService().deleteProduct(productId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${p.name}')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManageVariants(Product p) {
    List<String> currentSizes = List.from(p.availableSizes);
    List<String> currentColors = List.from(p.availableColors);
    final String productId = p.id.isNotEmpty ? p.id : p.name;
    final TextEditingController priceCtrl = TextEditingController(text: p.price.toStringAsFixed(2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSb) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24.0, right: 24.0, top: 24.0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage: ${p.name}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),

                const Text('Update Price', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.currency_rupee, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      onPressed: () async {
                        final newPrice = double.tryParse(priceCtrl.text);
                        if (newPrice != null) {
                          await DatabaseService().updateProduct(productId, {'price': newPrice});
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Price updated successfully!'))
                            );
                            Navigator.pop(ctx);
                          }
                        }
                      },
                      child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('Sizes (Tap to remove)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                const SizedBox(height: 8),
                currentSizes.isEmpty 
                  ? const Text('No sizes defined.', style: TextStyle(color: AppColors.grey))
                  : Wrap(
                      spacing: 8,
                      children: currentSizes.map((size) => InputChip(
                        label: Text(size),
                        deleteIconColor: AppColors.error,
                        onDeleted: () async {
                          setStateSb(() => currentSizes.remove(size));
                          await DatabaseService().updateProduct(productId, {'availableSizes': currentSizes});
                        },
                      )).toList(),
                    ),
                
                const SizedBox(height: 24),

                const Text('Colors (Tap to remove)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                const SizedBox(height: 8),
                currentColors.isEmpty 
                  ? const Text('No colors defined.', style: TextStyle(color: AppColors.grey))
                  : Wrap(
                      spacing: 8,
                      children: currentColors.map((color) => InputChip(
                        label: Text(color),
                        deleteIconColor: AppColors.error,
                        onDeleted: () async {
                          setStateSb(() => currentColors.remove(color));
                          await DatabaseService().updateProduct(productId, {'availableColors': currentColors});
                        },
                      )).toList(),
                    ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Products', style: TextStyle(color: AppColors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUploadScreen()),
          );
        },
      ),
      body: StreamBuilder<List<Product>>(
        stream: DatabaseService().getProductsStream('All'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('No products available.', style: TextStyle(color: AppColors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                        : Container(width: 50, height: 50, color: Colors.grey.shade300),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tap to manage colors & sizes', style: TextStyle(fontSize: 12, color: AppColors.primaryRed)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _confirmDelete(p),
                  ),
                  onTap: () => _showManageVariants(p),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
