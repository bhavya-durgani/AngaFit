import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import '../../core/constants/app_colors.dart'; // App color constants
import 'payment_selection_screen.dart'; // Payment screen
import 'address_selection_screen.dart'; // Address selection screen

// Stateful widget for Checkout screen
class CheckoutScreen extends StatefulWidget {

  final double total; // Total price passed from cart
  final int count; // Number of items
  final List<Map<String, dynamic>>? directItems; // Items if direct buy

  const CheckoutScreen({
    super.key,
    required this.total,
    required this.count,
    this.directItems
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

// State class (handles logic + UI updates)
class _CheckoutScreenState extends State<CheckoutScreen> {

  bool isLoadingAddress = true; // Loading state for address
  Map<String, String>? selectedAddressData; // Selected address data

  @override
  void initState() {
    super.initState();

    // Load default address when screen opens
    _loadDefaultAddress();
  }

  // Function to load default address from Firestore
  Future<void> _loadDefaultAddress() async {

    // Get current logged-in user ID
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // If no user → stop loading
    if (uid == null) {
      setState(() => isLoadingAddress = false);
      return;
    }

    try {
      // Fetch first address (oldest or default logic)
      final snapshot = await FirebaseFirestore.instance
          .collection('users') // Users collection
          .doc(uid) // Current user
          .collection('addresses') // Addresses subcollection
          .orderBy('createdAt', descending: false) // Oldest first
          .limit(1) // Only 1 address
          .get();

      // If address exists
      if (snapshot.docs.isNotEmpty) {

        final data = snapshot.docs.first.data(); // Get address data

        final label = data['label'] ?? "Address"; // Label (Home/Work)

        // Create full address string
        final fullAddress =
            "${data['street']}, ${data['city']}, ${data['state']} ${data['zip']}";

        // Update UI
        setState(() {
          selectedAddressData = {
            'label': label,
            'name': data['name'],
            'address': fullAddress,
          };
          isLoadingAddress = false; // Stop loading
        });

      } else {
        // No address found
        setState(() {
          isLoadingAddress = false;
        });
      }

    } catch (e) {
      // Error handling
      setState(() {
        isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // BILLING CALCULATIONS
    final double subtotal = widget.total; // Base amount
    final double tax = subtotal * 0.05; // 5% tax
    final double deliveryFee = subtotal >= 5000 ? 0 : 50.0; // Delivery charge
    final double grandTotal = subtotal + tax + deliveryFee; // Final total

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("Order Summary"),
        centerTitle: true
      ),

      body: SingleChildScrollView( // Scrollable screen

        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // HEADER: Shipping Address
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  "Shipping Address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),

                // Change address button
                TextButton(
                  onPressed: () async {

                    // Open address selection screen
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressSelectionScreen()
                      ),
                    );

                    // If user selected address → update UI
                    if (result != null &&
                        result is Map<String, String> &&
                        mounted) {
                      setState(() => selectedAddressData = result);
                    }
                  },

                  child: const Text(
                    "CHANGE",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ADDRESS DISPLAY
            isLoadingAddress
                ? const Center(child: CircularProgressIndicator()) // Show loader

                : selectedAddressData == null
                    // No address selected
                    ? _buildAddressCard(
                        "No Address",
                        "Please add a shipping address"
                      )

                    // Show selected address
                    : _buildAddressCard(
                        selectedAddressData!['label']!,
                        "${selectedAddressData!['name']}\n${selectedAddressData!['address']}"
                      ),

            const SizedBox(height: 28),

            // ORDER DETAILS TITLE
            const Text(
              "Order Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            const SizedBox(height: 12),

            // ORDER SUMMARY BOX
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)
              ),

              child: Column(
                children: [

                  // Item count
                  _summaryRow(
                    widget.directItems != null
                        ? "Direct Purchase"
                        : "Items in Cart",
                    "${widget.count}"
                  ),

                  const SizedBox(height: 4),

                  // Subtotal
                  _summaryRow(
                    "Subtotal",
                    "₹${subtotal.toStringAsFixed(0)}"
                  ),

                  const SizedBox(height: 4),

                  // Tax
                  _summaryRow(
                    "Tax (5%)",
                    "₹${tax.toStringAsFixed(0)}"
                  ),

                  const SizedBox(height: 4),

                  // Delivery fee
                  _summaryRow(
                    "Delivery Fee",
                    deliveryFee == 0
                        ? "Free"
                        : "₹${deliveryFee.toStringAsFixed(0)}"
                  ),

                  const Divider(height: 24, thickness: 1),

                  // Final total
                  _summaryRow(
                    "Total Payable",
                    "₹${grandTotal.toStringAsFixed(0)}",
                    isBold: true
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                // If no address → show error
                onPressed: selectedAddressData == null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please select a shipping address first."),
                            backgroundColor: Colors.red
                          ),
                        );
                      }

                    // If address selected → go to payment screen
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentSelectionScreen(
                              totalAmount: grandTotal,
                              directItems: widget.directItems,
                              address:
                                  "${selectedAddressData!['name']}\n${selectedAddressData!['address']}",
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

  // Widget to display address card
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
              const Icon(Icons.location_on,
                  color: AppColors.primaryRed, size: 20),

              const SizedBox(width: 8),

              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 8),

          // Address text
          Text(
            sub,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 13,
              height: 1.4
            )
          ),
        ],
      ),
    );
  }

  // Row for summary (label + value)
  Widget _summaryRow(String l, String v, {bool isBold = false}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(
            l,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal
            )
          ),

          Text(
            v,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isBold
                  ? AppColors.primaryRed
                  : AppColors.black
            )
          ),
        ],
      ),
    );
  }
}
