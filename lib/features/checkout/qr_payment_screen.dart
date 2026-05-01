import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:qr_flutter/qr_flutter.dart'; // Library to generate QR codes
import 'package:provider/provider.dart'; // State management (Provider)
import '../../core/constants/app_colors.dart'; // App colors
import '../../core/utils/cart_provider.dart'; // Cart state handler
import '../../data/services/database_service.dart'; // Database service
import '../cart/success_screen.dart'; // Success screen after payment

// Stateless widget (no internal state needed)
class QrPaymentScreen extends StatelessWidget {

  final double totalAmount; // Total amount to pay
  final List<Map<String, dynamic>>? directItems; // Items (if direct purchase)
  final String? address; // Selected address

  const QrPaymentScreen({
    super.key,
    required this.totalAmount,
    this.directItems,
    this.address
  });

  @override
  Widget build(BuildContext context) {

    // Create QR data string (UPI payment link)
    final String qrData =
        "upi://pay?pa=admin@upi&pn=AngaFit&am=${totalAmount.toStringAsFixed(2)}";

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("Scan to Pay"), // Title
        centerTitle: true
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              // Instruction text
              const Text(
                "Scan the QR code below using any UPI app to make the payment.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 32),

              // QR CODE CONTAINER
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2
                    )
                  ],
                ),

                // QR IMAGE
                child: QrImageView(
                  data: qrData, // Data inside QR
                  version: QrVersions.auto, // Auto size version
                  size: 250.0, // Size of QR
                ),
              ),

              const SizedBox(height: 32),

              // Show total amount
              Text(
                "Amount: ₹${totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed
                ),
              ),

              const SizedBox(height: 48),

              // BUTTON: Confirm payment
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: () async {

                    // Show loading spinner
                    showDialog(
                      context: context,
                      barrierDismissible: false, // User cannot close manually
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {

                      // 1. Create order in Firestore
                      await DatabaseService().createOrder(
                        totalAmount,
                        directItems: directItems,
                        address: address,
                        paymentMethod: "QR",
                      );

                      // 2. Small delay (for better UX)
                      await Future.delayed(const Duration(seconds: 1));

                      if (context.mounted) {

                        // Clear cart (if order came from cart)
                        Provider.of<CartProvider>(
                          context,
                          listen: false
                        ).clearCart();

                        Navigator.pop(context); // Close loading dialog

                        // Navigate to success screen and remove old screens
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

                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red
                          ),
                        );
                      }
                    }
                  },

                  child: const Text("I HAVE PAID"), // Button text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
