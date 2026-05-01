import 'package:flutter/material.dart'; // Flutter UI package
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore database package
import 'package:intl/intl.dart'; // For formatting date and time
import '../../core/constants/app_colors.dart'; // Custom app colors
import '../../data/services/database_service.dart'; // Database service for Firestore operations

class ManageOrdersScreen extends StatefulWidget { // Stateful widget to manage orders screen
  const ManageOrdersScreen({super.key}); // Constructor

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState(); // Create state
}

  final List<String> _statuses = [ // List of all possible order statuses
    'Pending',
    'Processing',
    'Packed',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  Color _getStatusColor(String status) { // Function to return color based on status
    switch (status) {
      case 'Pending': return Colors.orange; // Pending → orange
      case 'Processing': return Colors.blue; // Processing → blue
      case 'Packed': return Colors.purple; // Packed → purple
      case 'Shipped': return Colors.indigo; // Shipped → indigo
      case 'Delivered': return Colors.green; // Delivered → green
      case 'Cancelled': return AppColors.error; // Cancelled → error color
      default: return AppColors.grey; // Default → grey
    }
  }

  void _updateStatus(DocumentReference orderRef, String currentStatus) {  // Function to update order status
    String selectedStatus = currentStatus;  // Initially selected status is current status
    
    showModalBottomSheet(  // Show bottom sheet
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),  // Rounded top corners
      ),
      builder: (ctx) => StatefulBuilder(  // Stateful builder to manage local state inside bottom sheet
        builder: (ctx, setStateSb) => Container(
          padding: const EdgeInsets.all(24),  // Padding inside bottom sheet
          child: Column(
            mainAxisSize: MainAxisSize.min,  // Take minimum height
            children: [
              
              const Text(
                'Update Order Status',  // Title text
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 16),  // Spacing
              
              DropdownButtonFormField<String>(  // Dropdown for selecting new status
                value: _statuses.contains(currentStatus) ? currentStatus : _statuses.first,  // Set default value
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))  // Convert list into dropdown items
                    .toList(),
                onChanged: (v) {
                  if (v != null) setStateSb(() => selectedStatus = v);  // Update selected status
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),  // Border styling
                  filled: true,
                  fillColor: Colors.grey.shade100,  // Background color
                ),
              ),
              const SizedBox(height: 24),  // Spacing
              SizedBox(
                width: double.infinity,  // Full width button
                child: ElevatedButton(
                  onPressed: () async {  // On button press
                    Navigator.pop(ctx);  // Close bottom sheet
                    if (selectedStatus != currentStatus) {   // Only update if changed
                      try {
                        await DatabaseService().updateOrderStatus(orderRef, selectedStatus);  // Update in Firestore
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Status updated successfully!')),  // Success message
                          );
                        }
                      } catch(e) {
                         if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),  // Error message
                          );
                        }
                      }
                    }
                  },
                  child: const Text('SAVE CHANGES'),   // Button text
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {   // Build UI
    return Scaffold(
      backgroundColor: AppColors.background,  // Screen background color
      appBar: AppBar(
        title: const Text('Manage Orders', style: TextStyle(color: AppColors.black)),  // Title
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),  // Back button icon
          onPressed: () => Navigator.pop(context),   // Navigate back
        ),  
      ),
      body: StreamBuilder<QuerySnapshot>(  // Listen to real-time Firestore data
        stream: DatabaseService().getAllOrdersAdminStream(),  // Stream of all orders
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {   // While loading
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
          }
          if (snapshot.hasError) {   // If error occurs
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  "Error fetching orders:\n\n${snapshot.error}",    // Show error message
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              )
            );
          }

          final docs = snapshot.data?.docs ?? [];   // Show error message

          if (docs.isEmpty) {  // If no orders
            return const Center(
              child: Text("No orders found across the platform.", style: TextStyle(color: AppColors.grey)),
            );
          }

          return ListView.builder(  // List of orders
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              
              final doc = docs[index];   // Get single document
              final data = doc.data() as Map<String, dynamic>;  // Convert to map

              final status = data['status'] ?? 'Pending'; // Get status
              final orderId = data['orderId'] ?? doc.id; // Get order ID
              final total = data['total'] ?? 0.0; // Get total amount
              final itemsCount = data['itemsCount'] ?? 0; // Number of items
              final paymentMethod = data['paymentMethod'] ?? 'Unknown'; // Payment method

              String dateStr = ''; // Date string
              final ts = data['createdAt']; // Timestamp
              
              if (ts is Timestamp) {
                dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(ts.toDate());  // Format date
              }

              return Card(   // Order card UI
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _updateStatus(doc.reference, status),   // Open update sheet
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Order #$orderId',   // Show order ID
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withAlpha(30),   // Light background color
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateStr,   // Show date
                          style: const TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$itemsCount items'),   // Items count
                            Text(
                              '₹${total.toStringAsFixed(2)}',   // Total price
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Payment: $paymentMethod',    // Payment method
                             style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                        
                        const Divider(height: 24),  // Divider line
                        
                        const Center(
                          child: Text(
                            'TAP TO CHANGE STATUS',  // Instruction
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
