import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({super.key, required this.orderId, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = orderData['items'] ?? [];
    final DateTime? createdAt = orderData['createdAt'] != null ? (orderData['createdAt'] as Timestamp).toDate() : null;
    final String dateStr = createdAt != null ? DateFormat('dd MMM yyyy, HH:mm').format(createdAt) : "N/A";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Order Details"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Order ID: ${orderId.substring(0, 8).toUpperCase()}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(dateStr, style: const TextStyle(color: AppColors.grey)),
              ],
            ),
            const SizedBox(height: 24),

            // Tracking Timeline
            const Text("Order Tracking", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildTrackingTimeline(orderData['status'] ?? "Pending"),
            
            const Divider(height: 48),

            // Items List
            Text("${items.length} Items", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildItemRow(item);
              },
            ),

            const Divider(height: 48),

            // Order Summary
            const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _infoRow("Subtotal", "₹${orderData['total']}"),
            _infoRow("Shipping", "Free"),
            _infoRow("Payment Method", orderData['paymentMethod'] == 'COD' ? "Cash on Delivery" : (orderData['paymentMethod'] == 'QR' ? "UPI / QR" : (orderData['paymentMethod'] ?? "Unknown"))),
            const Divider(height: 24),
            _infoRow("Total Amount", "₹${orderData['total']}", isBold: true),

            const SizedBox(height: 32),
            const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
                orderData['deliveryAddress'] ?? "3 Newbridge Court, Chino Hills, CA 91709, USA",
                style: const TextStyle(color: AppColors.grey, height: 1.4)
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("BACK TO ORDERS"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline(String status) {
    final stages = ["Pending", "Confirmed", "Shipped", "Delivered"];
    int currentStage = stages.indexOf(status);
    if (currentStage == -1) currentStage = 0; // Default to Pending

    return Column(
      children: List.generate(stages.length, (index) {
        bool isCompleted = index <= currentStage;
        bool isLast = index == stages.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? AppColors.success : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stages[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.black : AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted ? "Completed" : "Expected",
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item['imageUrl'] ?? "",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey.shade200),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'] ?? "Product", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${item['brand'] ?? ""} • Size: ${item['size'] ?? ""}", style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
        ),
        Text("${item['quantity']} x ₹${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? AppColors.black : AppColors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isBold ? AppColors.primaryRed : AppColors.black, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }
}
