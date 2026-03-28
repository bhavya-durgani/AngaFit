import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cart_provider.dart';
import '../../data/services/database_service.dart';
import '../cart/success_screen.dart';
import 'qr_payment_screen.dart';
class PaymentSelectionScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>>? directItems;
  final String? address;
  const PaymentSelectionScreen({super.key, required this.totalAmount, this.directItems, this.address});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String selectedMethod = "QR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Payment Method"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Payment Options", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _methodTile("Scan QR for Payment", "Pay using UPI apps", Icons.qr_code_2, "QR"),
                  const SizedBox(height: 12),
                  _methodTile("Cash on Delivery", "Pay at doorstep", Icons.handshake, "COD"),
                ],
              ),
            ),
          ),
          _buildPriceFooter(),
        ],
      ),
    );
  }

  Widget _methodTile(String title, String sub, IconData icon, String value) {
    bool isSelected = selectedMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primaryRed : Colors.transparent, width: 2),
      ),
      child: RadioListTile(
        value: value,
        groupValue: selectedMethod,
        activeColor: AppColors.primaryRed,
        onChanged: (v) => setState(() => selectedMethod = v.toString()),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        secondary: Icon(icon, color: AppColors.black),
      ),
    );
  }

  Widget _buildPriceFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Total Payable", style: TextStyle(color: AppColors.grey, fontSize: 12)),
              Text("₹${widget.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () async {
                if (selectedMethod == "QR") {
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
                } else if (selectedMethod == "COD") {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  try {
                    // Create order
                    await DatabaseService().createOrder(
                      widget.totalAmount, 
                      directItems: widget.directItems,
                      address: widget.address,
                      paymentMethod: "COD",
                    );
                    
                    await Future.delayed(const Duration(seconds: 1));
                    
                    if (context.mounted) {
                      Provider.of<CartProvider>(context, listen: false).clearCart(); // Sync local state IF it was from cart
                      Navigator.pop(context); // close dialog
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SuccessScreen()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
