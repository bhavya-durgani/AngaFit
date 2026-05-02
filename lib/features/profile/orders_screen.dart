import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import '../../core/constants/app_colors.dart'; // Custom app colors
import 'order_details_screen.dart'; // Screen to show order details

import 'package:intl/intl.dart'; // For formatting date

// Stateless widget since UI depends only on stream data (no manual state)
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    // Get current logged-in user's UID
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background, // App background color
      appBar: AppBar(title: const Text("My Orders"), centerTitle: true), // Top app bar

      // StreamBuilder listens to real-time updates from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users') // Go to users collection
            .doc(uid) // Select current user document
            .collection('orders') // Go to user's orders collection
            .orderBy('createdAt', descending: true) // Latest orders first
            .snapshots(), // Real-time stream

        builder: (context, snapshot) {
          // If error occurs while fetching data
          if (snapshot.hasError) 
            return Center(child: Text("Error: ${snapshot.error}"));

          // If data is still loading
          if (!snapshot.hasData) 
            return const Center(child: CircularProgressIndicator());

          // Extract list of order documents
          final docs = snapshot.data!.docs;

          // If no orders exist
          if (docs.isEmpty) 
            return const Center(child: Text("No orders placed yet."));

          // Build list of orders
          return ListView.builder(
            padding: const EdgeInsets.all(16), // Padding around list
            itemCount: docs.length, // Total number of orders
            itemBuilder: (context, index) {
              // Convert document data into Map
              final data = docs[index].data() as Map<String, dynamic>;

              // Build each order card
              return _buildOrderCard(context, docs[index].id, data);
            },
          );
        },
      ),
    );
  }

  // Function to build UI for each order card
  Widget _buildOrderCard(BuildContext context, String orderId, Map<String, dynamic> data) {

    // Convert Firestore Timestamp to DateTime
    final DateTime? createdAt = data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : null;

    // Format date into readable string
    final String dateStr = createdAt != null 
        ? DateFormat('dd-MM-yyyy HH:mm').format(createdAt) 
        : "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Space between cards
      padding: const EdgeInsets.all(16), // Inner padding
      decoration: BoxDecoration(
        color: Colors.white, // Card background
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ], // Shadow effect
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
        children: [

          // Row for Order ID and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Order ID: ${orderId.substring(0, 8).toUpperCase()}", // Show short ID
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis, // Avoid overflow
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8), // Space between text
              Text(dateStr, style: const TextStyle(color: AppColors.grey, fontSize: 12)), // Show date
            ],
          ),

          const Divider(height: 24), // Divider line

          // Row for Quantity and Total price
          Row(
            children: [
              const Text("Quantity: ", style: TextStyle(color: AppColors.grey)), // Label
              Text("${data['itemsCount'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)), // Items count

              const Spacer(), // Push next items to right

              const Text("Total: ", style: TextStyle(color: AppColors.grey)), // Label
              Text(
                "₹${data['total']}", // Total price
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed),
              ),
            ],
          ),

          const SizedBox(height: 16), // Space

          // Row for status and view details button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Status badge (Delivered / Pending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // Green if delivered, else orange
                  color: (data['status'] == 'Delivered') 
                      ? AppColors.success.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data['status'] ?? "Pending", // Show status
                  style: TextStyle(
                    color: (data['status'] == 'Delivered') 
                        ? AppColors.success 
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Button to view order details
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(
                      orderId: orderId, // Pass order ID
                      orderData: data,  // Pass full order data
                    )
                  )
                ),
                child: const Text(
                  "VIEW DETAILS",
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold
                  )
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
