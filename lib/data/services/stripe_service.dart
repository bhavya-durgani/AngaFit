import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../../features/cart/success_screen.dart';

class StripeService {
  Map<String, dynamic>? paymentIntent;

  // 1. MAIN FUNCTION: Triggers the whole payment flow
  Future<void> makePayment(BuildContext context, double amount) async {
    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create a Payment Intent on Stripe Servers
      paymentIntent = await createPaymentIntent(amount.toStringAsFixed(0), 'INR');

      if (paymentIntent == null) {
        if (context.mounted) Navigator.pop(context); // Close loading dialog
        debugPrint("Stripe Error: Could not create Payment Intent");
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to initialize payment. Please try again later."), backgroundColor: Colors.red));
        }
        return;
      }

      // Initialize the Payment Sheet UI
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'AngaFit AR Store',
        ),
      );

      if (context.mounted) Navigator.pop(context); // Close loading dialog before presenting sheet

      // Show the Payment Sheet to the user
      if (!context.mounted) return;
      await displayPaymentSheet(context);
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading dialog on error
      debugPrint("Stripe Initialization Error: $e");
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stripe Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  // 2. DISPLAY: Opens the bottom sheet for card entry
  displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // SUCCESS REDIRECTION
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SuccessScreen()),
              (route) => false,
        );
        paymentIntent = null;
      });
    } on StripeException catch (e) {
      debugPrint('Payment Cancelled or Failed: $e');
    }
  }

  // 3. SERVER CALL: Requests a secret key from Stripe
  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      
      // Enforce a minimum of 100 INR for testing to avoid "Amount must be at least ₹50.00" errors
      int parsedAmount = int.tryParse(amount) ?? 100;
      if (parsedAmount < 100) parsedAmount = 100;

      Map<String, dynamic> body = {
        'amount': '${parsedAmount}00', // Amount in paise (₹1 = 100 paise)
        'currency': currency,
        // Remove payment_method_types to allow Stripe to automatically use all configured methods
        // 'payment_method_types[]': 'card', 
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51T2sfBPAvUbK5SvGvFpgYxREzlxe6uJ8EvY9Op8bow7qKURcB3MHxwCMp1eudweTNsvq91UtMskx3aPodm9bMm5V00MdXiALTY', // Replace with your sk_test_...
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Stripe API Error: ${response.statusCode} - ${response.body}');
        return null; // Return null so the frontend handles it gracefully
      }
    } catch (err) {
      debugPrint('Error creating intent: ${err.toString()}');
      return null;
    }
  }
}
