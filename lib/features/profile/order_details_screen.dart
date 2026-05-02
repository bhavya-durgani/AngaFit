import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for Timestamp handling
import '../../core/constants/app_colors.dart'; // App color constants

import 'package:intl/intl.dart'; // For date formatting

// Stateless widget to display order details
class OrderDetailsScreen extends StatelessWidget {
  final String orderId; // Order ID
  final Map<String, dynamic> orderData; // Order data map

  // Constructor
  const OrderDetailsScreen({
    super.key, 
    required this.orderId, 
    required this.orderData
  });

  @override
  Widget build(BuildContext context) {

    final List<dynamic> items = orderData['items'] ?? []; // List of order items

    // Convert Firestore timestamp to DateTime
    final DateTime? createdAt = orderData['createdAt'] != null 
        ? (orderData['createdAt'] as Timestamp).toDate() 
        : null;

    // Format date into readable string
    final String dateStr = createdAt != null 
        ? DateFormat('dd MMM yyyy, HH:mm').format(createdAt) 
        : "N/A";

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("Order Details"), // App bar title
        centerTitle: true, // Center title
      ),

      body: SingleChildScrollView( // Scrollable content
        padding: const EdgeInsets.all(16), // Padding

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Left alignment

          children: [

            // Order ID and Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Expanded(
                  child: Text(
                    "Order ID: ${orderId.substring(0, 8).toUpperCase()}", // Show short order ID
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis, // Handle overflow
                    maxLines: 1,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  dateStr, // Show formatted date
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tracking Timeline Title
            const Text(
              "Order Tracking", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            const SizedBox(height: 16),

            // Call timeline builder
            _buildTrackingTimeline(orderData['status'] ?? "Pending"),

            const Divider(height: 48),

            // Items Section Title
            Text(
              "${items.length} Items",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            const SizedBox(height: 16),

            // List of items
            ListView.separated(
              shrinkWrap: true, // Wrap inside column
              physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
              itemCount: items.length, // Number of items

              separatorBuilder: (_, __) => const SizedBox(height: 16),

              itemBuilder: (context, index) {
                final item = items[index]; // Get item
                return _buildItemRow(item); // Build UI for item
              },
            ),

            const Divider(height: 48),

            // Order Summary Title
            const Text(
              "Order Summary", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            const SizedBox(height: 16),

            // Summary rows
            _infoRow("Subtotal", "₹${orderData['total']}"), // Subtotal
            _infoRow("Shipping", "Free"), // Shipping

            // Payment method logic
            _infoRow(
              "Payment Method",
              orderData['paymentMethod'] == 'COD'
                  ? "Cash on Delivery"
                  : (orderData['paymentMethod'] == 'QR'
                      ? "UPI / QR"
                      : (orderData['paymentMethod'] ?? "Unknown")),
            ),

            const Divider(height: 24),

            // Total amount
            _infoRow(
              "Total Amount", 
              "₹${orderData['total']}", 
              isBold: true
            ),

            const SizedBox(height: 32),

            // Delivery Address Title
            const Text(
              "Delivery Address",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            const SizedBox(height: 8),

            // Address text
            Text(
              orderData['deliveryAddress'] ?? 
              "3 Newbridge Court, Chino Hills, CA 91709, USA",
              style: const TextStyle(
                color: AppColors.grey, 
                height: 1.4
              )
            ),

            const SizedBox(height: 40),

            // Back button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), // Go back
                child: const Text("BACK TO ORDERS"),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ───────── Tracking Timeline Widget ─────────
  Widget _buildTrackingTimeline(String status) {

    final stages = ["Pending", "Confirmed", "Shipped", "Delivered"]; // Order stages

    int currentStage = stages.indexOf(status); // Current stage index
    if (currentStage == -1) currentStage = 0; // Default to Pending

    return Column(
      children: List.generate(stages.length, (index) {

        bool isCompleted = index <= currentStage; // Completed step
        bool isLast = index == stages.length - 1; // Last step

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // Timeline indicator (circle + line)
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,

                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AppColors.success 
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),

                  child: isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),

                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted 
                        ? AppColors.success 
                        : Colors.grey.shade300,
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Stage text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    stages[index], // Stage name
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted 
                          ? AppColors.black 
                          : AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isCompleted ? "Completed" : "Expected", // Status text
                    style: const TextStyle(
                      fontSize: 12, 
                      color: AppColors.grey
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ───────── Item Row UI ─────────
  Widget _buildItemRow(Map<String, dynamic> item) {
    return Row(
      children: [

        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),

          child: Image.network(
            item['imageUrl'] ?? "", // Image URL
            width: 60,
            height: 60,
            fit: BoxFit.cover,

            // Fallback if image fails
            errorBuilder: (_, __, ___) =>
                Container(width: 60, height: 60, color: Colors.grey.shade200),
          ),
        ),

        const SizedBox(width: 12),

        // Product details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                item['name'] ?? "Product",
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),

              Text(
                "${item['brand'] ?? ""} • Size: ${item['size'] ?? ""}",
                style: const TextStyle(
                  color: AppColors.grey, 
                  fontSize: 12
                ),
              ),
            ],
          ),
        ),

        // Price and quantity
        Text(
          "${item['quantity']} x ₹${item['price']}",
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  // ───────── Info Row (Reusable) ─────────
  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          // Label
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppColors.black : AppColors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal
            ),
          ),

          // Value
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBold 
                  ? AppColors.primaryRed 
                  : AppColors.black,
              fontSize: isBold ? 18 : 14
            ),
          ),
        ],
      ),
    );
  }
}
