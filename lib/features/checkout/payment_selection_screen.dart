import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:provider/provider.dart'; // State management (Provider)
import '../../core/constants/app_colors.dart'; // App colors
import '../../core/utils/cart_provider.dart'; // Cart state handler
import '../../data/services/database_service.dart'; // Database service (Firestore)
import '../cart/success_screen.dart'; // Success screen after order
import 'qr_payment_screen.dart'; // QR payment screen

// Stateful widget because payment method can change
class PaymentSelectionScreen extends StatefulWidget {

  final double totalAmount; // Total amount to pay
  final List<Map<String, dynamic>>? directItems; // Items if direct purchase
  final String? address; // Selected address

  const PaymentSelectionScreen({
    super.key,
    required this.totalAmount,
    this.directItems,
    this.address
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

// State class
class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {

  String selectedMethod = "QR"; // Default payment method

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("Payment Method"), // Title
        centerTitle: true
      ),

      body: Column(
        children: [

          // MAIN CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // Title
                  const Text(
                    "Payment Options",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),

                  const SizedBox(height: 12),

                  // QR Payment option
                  _methodTile(
                    "Scan QR for Payment",
                    "Pay using UPI apps",
                    Icons.qr_code_2,
                    "QR"
                  ),

                  const SizedBox(height: 12),

                  // Cash on Delivery option
                  _methodTile(
                    "Cash on Delivery",
                    "Pay at doorstep",
                    Icons.handshake,
                    "COD"
                  ),
                ],
              ),
            ),
          ),

          // FOOTER (price + button)
          _buildPriceFooter(),
        ],
      ),
    );
  }

  // Widget for each payment method option
  Widget _methodTile(String title, String sub, IconData icon, String value) {

    bool isSelected = selectedMethod == value; // Check if selected

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        // Highlight selected option
        border: Border.all(
          color: isSelected ? AppColors.primaryRed : Colors.transparent,
          width: 2
        ),
      ),

      child: RadioListTile(
        value: value, // Option value
        groupValue: selectedMethod, // Currently selected value

        activeColor: AppColors.primaryRed,

        // When user selects option
        onChanged: (v) =>
            setState(() => selectedMethod = v.toString()),

        // Title
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),

        // Subtitle
        subtitle: Text(
          sub,
          style: const TextStyle(fontSize: 12, color: AppColors.grey)
        ),

        // Icon
        secondary: Icon(icon, color: AppColors.black),
      ),
    );
  }

  // Bottom section (price + pay button)
  Widget _buildPriceFooter() {

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 20 // Safe area padding
      ),

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          // PRICE DISPLAY
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: [

              const Text(
                "Total Payable",
                style: TextStyle(color: AppColors.grey, fontSize: 12)
              ),

              Text(
                "₹${widget.totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),

          // PAY BUTTON
          SizedBox(
            width: 160,

            child: ElevatedButton(

              onPressed: () async {

                // CASE 1: QR PAYMENT
                if (selectedMethod == "QR") {

                  // Navigate to QR screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrPaymentScreen(
                        totalAmount: widget.totalAmount,
                        directItems: widget.directItems,
                        address: widget.address,
                      ),
                    ),
                  );

                }

                // CASE 2: CASH ON DELIVERY
                else if (selectedMethod == "COD") {

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {

                    // Create order in database
                    await DatabaseService().createOrder(
                      widget.totalAmount,
                      directItems: widget.directItems,
                      address: widget.address,
                      paymentMethod: "COD",
                    );

                    // Small delay for UX
                    await Future.delayed(const Duration(seconds: 1));

                    if (context.mounted) {

                      // Clear cart locally
                      Provider.of<CartProvider>(
                        context,
                        listen: false
                      ).clearCart();

                      Navigator.pop(context); // Close loading dialog

                      // Go to success screen and remove all previous screens
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SuccessScreen()),
                        (route) => false,
                      );
                    }

                  } catch (e) {

                    // If error occurs
                    if (context.mounted) {

                      Navigator.pop(context); // Close loading

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red
                        ),
                      );
                    }
                  }
                }
              },

              child: const Text("PAY NOW"),
            ),
          ),
        ],
      ),
    );
  }
}
