import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cart_provider.dart';
import '../../data/services/database_service.dart';
import '../cart/success_screen.dart';

class QrPaymentScreen extends StatelessWidget {
  final double totalAmount;
  final List<Map<String, dynamic>>? directItems;
  final String? address;

  const QrPaymentScreen({super.key, required this.totalAmount, this.directItems, this.address});

  @override
  Widget build(BuildContext context) {
    // A dummy UPI or generic info link
    final String qrData = "upi://pay?pa=admin@upi&pn=AngaFit&am=${totalAmount.toStringAsFixed(2)}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Scan to Pay"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Scan the QR code below using any UPI app to make the payment.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 250.0,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Amount: ₹${totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Simulate confirming payment
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    try {
                      // 1. Create the Order in Firestore
                      await DatabaseService().createOrder(totalAmount, directItems: directItems, address: address, paymentMethod: "QR");
                      
                      // 2. Simulate small delay
                      await Future.delayed(const Duration(seconds: 1));
                      
                      if (context.mounted) {
                        Provider.of<CartProvider>(context, listen: false).clearCart(); // Sync local state IF it was from cart
                        Navigator.pop(context); // close loading dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const SuccessScreen()),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text("I HAVE PAID"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
