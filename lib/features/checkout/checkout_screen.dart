import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'payment_selection_screen.dart';
import 'address_selection_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double total;
  final int count;
  final List<Map<String, dynamic>>? directItems;

  const CheckoutScreen({super.key, required this.total, required this.count, this.directItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isLoadingAddress = true;
  Map<String, String>? selectedAddressData;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => isLoadingAddress = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final label = data['label'] ?? "Address";
        final fullAddress = "${data['street']}, ${data['city']}, ${data['state']} ${data['zip']}";
        setState(() {
          selectedAddressData = {
            'label': label,
            'name': data['name'],
            'address': fullAddress,
          };
          isLoadingAddress = false;
        });
      } else {
        setState(() {
          isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Billing Calculations
    final double subtotal = widget.total;
    final double tax = subtotal * 0.05; // 5% GST
    final double deliveryFee = subtotal >= 5000 ? 0 : 50.0;
    final double grandTotal = subtotal + tax + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Order Summary"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shipping Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressSelectionScreen()),
                    );
                    if (result != null && result is Map<String, String> && mounted) {
                      setState(() => selectedAddressData = result);
                    }
                  },
                  child: const Text("CHANGE", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isLoadingAddress
                ? const Center(child: CircularProgressIndicator())
                : selectedAddressData == null
                    ? _buildAddressCard("No Address", "Please add a shipping address")
                    : _buildAddressCard(selectedAddressData!['label']!,
                        "${selectedAddressData!['name']}\n${selectedAddressData!['address']}"),
            const SizedBox(height: 28),
            const Text("Order Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _summaryRow(widget.directItems != null ? "Direct Purchase" : "Items in Cart", "${widget.count}"),
                  const SizedBox(height: 4),
                  _summaryRow("Subtotal", "₹${subtotal.toStringAsFixed(0)}"),
                  const SizedBox(height: 4),
                  _summaryRow("Tax (5%)", "₹${tax.toStringAsFixed(0)}"),
                  const SizedBox(height: 4),
                  _summaryRow("Delivery Fee", deliveryFee == 0 ? "Free" : "₹${deliveryFee.toStringAsFixed(0)}"),
                  const Divider(height: 24, thickness: 1),
                  _summaryRow("Total Payable", "₹${grandTotal.toStringAsFixed(0)}", isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAddressData == null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select a shipping address first."), backgroundColor: Colors.red),
                        );
                      }
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentSelectionScreen(
                              totalAmount: grandTotal,
                              directItems: widget.directItems,
                              address: "${selectedAddressData!['name']}\n${selectedAddressData!['address']}",
                            ),
                          ),
                        ),
                child: const Text("CONTINUE TO PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primaryRed, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(sub, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _summaryRow(String l, String v, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(v, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: FontWeight.bold, color: isBold ? AppColors.primaryRed : AppColors.black)),
        ],
      ),
    );
  }
}
