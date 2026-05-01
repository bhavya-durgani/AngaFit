import 'package:flutter/material.dart'; // Flutter UI package
import '../../core/constants/app_colors.dart'; // Custom colors used in the app
import '../../data/dummy_data.dart'; // Product model and dummy data
import '../../data/services/database_service.dart'; // Firestore database service
import 'admin_upload_screen.dart'; // Screen to upload/add new product

class ManageProductsScreen extends StatefulWidget { // Stateful widget for managing products
  const ManageProductsScreen({super.key}); // Constructor

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState(); // Create state
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {  // State class
  void _confirmDelete(Product p) {  // Function to confirm product deletion
    showDialog(  // Show confirmation dialog
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),   // Dialog title
        content: Text('Are you sure you want to completely delete "${p.name}"? This action cannot be undone.'),   // Warning message
        actions: [
          TextButton(  // Cancel button
            onPressed: () => Navigator.pop(ctx),   // Close dialog
            child: const Text('CANCEL')),
          ElevatedButton(  // Delete button
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),  // Red color
            onPressed: () async {
              Navigator.pop(ctx);  // Close dialog
              try {
                // If id is empty, fallback to product name (as it was used before)
                final productId = p.id.isNotEmpty ? p.id : p.name;  // Determine document ID
                await DatabaseService().deleteProduct(productId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${p.name}')),  // Success message
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),  // Error message
                  );
                }
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),  // Button text
          ),
        ],
      ),
    );
  }

  void _showManageVariants(Product p) {  // Function to manage sizes, colors, price
    
    List<String> currentSizes = List.from(p.availableSizes);  // Copy current sizes
    List<String> currentColors = List.from(p.availableColors);  // Copy current colors
    
    final String productId = p.id.isNotEmpty ? p.id : p.name;  // Get product ID
    
    final TextEditingController priceCtrl = TextEditingController(  // Controller for price field
      text: p.price.toStringAsFixed(2));  // Set initial price value

    showModalBottomSheet(  // Bottom sheet UI
      context: context,
      isScrollControlled: true,  // Allow keyboard adjustment
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),  // Rounded top
      builder: (ctx) => StatefulBuilder(  // Local state inside bottom sheet
        builder: (ctx, setStateSb) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24.0, right: 24.0, top: 24.0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,  // Adjust for keyboard
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage: ${p.name}',   // Title with product name
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),

                const Text(  // Price section title
                  'Update Price', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                
                const SizedBox(height: 8),
                
                Row(  // Price input + save button
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,  // Controller
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),  // Numeric input
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.currency_rupee, size: 16),   // ₹ icon
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    ElevatedButton(  // Save price button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      onPressed: () async {
                        final newPrice = double.tryParse(priceCtrl.text);  // Parse price
                        
                        if (newPrice != null) {
                          await DatabaseService().updateProduct(productId, {'price': newPrice});  // Update Firestore

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Price updated successfully!'))
                            );
                            Navigator.pop(ctx);  // Close bottom sheet
                          }
                        }
                      },
                      child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                const Text(  // Sizes section
                  'Sizes (Tap to remove)', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                
                const SizedBox(height: 8),
                
                currentSizes.isEmpty 
                  ? const Text('No sizes defined.', style: TextStyle(color: AppColors.grey))   // If no sizes
                  : Wrap(
                      spacing: 8,
                      children: currentSizes.map((size) => InputChip(
                        label: Text(size),  // Size label
                        deleteIconColor: AppColors.error,   // Delete icon color
                        onDeleted: () async {
                          setStateSb(() => currentSizes.remove(size));  // Remove locally
                          await DatabaseService().updateProduct(productId, {'availableSizes': currentSizes});  // Update DB
                        },
                      )).toList(),
                    ),
                
                const SizedBox(height: 24),

                const Text(  // Colors section
                  'Colors (Tap to remove)', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
                
                const SizedBox(height: 8),
                
                currentColors.isEmpty 
                  ? const Text('No colors defined.', style: TextStyle(color: AppColors.grey))
                  : Wrap(
                      spacing: 8,
                      children: currentColors.map((color) => InputChip(
                        label: Text(color),
                        deleteIconColor: AppColors.error,
                        onDeleted: () async {
                          setStateSb(() => currentColors.remove(color));  // Remove color
                          await DatabaseService().updateProduct(productId, {'availableColors': currentColors});  // Update DB
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
  Widget build(BuildContext context) {  // UI build
    return Scaffold(
      backgroundColor: AppColors.background,  // Background color
      
      appBar: AppBar(
        title: const Text('Manage Products', style: TextStyle(color: AppColors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),  // Back navigation
        ),
      ),
      
      floatingActionButton: FloatingActionButton(  // Add product button
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUploadScreen()),  // Add product button
          );
        },
      ),
      
      body: StreamBuilder<List<Product>>(   // Real-time product list
        stream: DatabaseService().getProductsStream('All'),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));  // Loading 
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));  // Error
          }
          
          final products = snapshot.data ?? [];  // Product list

          if (products.isEmpty) {
            return const Center(child: Text('No products available.', style: TextStyle(color: AppColors.grey)));
          }

          return ListView.builder(  // Product list UI
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            
            itemBuilder: (context, index) {
              
              final p = products[index];  // Single product
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                
                child: ListTile(
                  
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover)  // Product image
                        : Container(width: 50, height: 50, color: Colors.grey.shade300),  // Placeholder
                  ),
                  
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),  // Product name
                  
                  subtitle: const Text(
                    'Tap to manage colors & sizes', 
                    style: TextStyle(fontSize: 12, color: AppColors.primaryRed)),
                  
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _confirmDelete(p),  // Delete action
                  ),
                  
                  onTap: () => _showManageVariants(p),  // Open edit bottom sheet
                ),
              );
            },
          );
        },
      ),
    );
  }
}
