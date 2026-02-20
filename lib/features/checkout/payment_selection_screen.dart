import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/stripe_service.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final double totalAmount;
  const PaymentSelectionScreen({super.key, required this.totalAmount});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String selectedMethod = "Stripe";

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
                  const Text("Recommended", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _methodTile("Credit / Debit Card", "Powered by Stripe", Icons.credit_card, "Stripe"),
                  const SizedBox(height: 24),
                  const Text("Other Methods", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _methodTile("Google Pay", "Fast and Secure", Icons.account_balance_wallet, "GPay"),
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
              onPressed: () {
                if (selectedMethod == "Stripe") {
                  StripeService().makePayment(context, widget.totalAmount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Method selected! Proceeding...")));
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
