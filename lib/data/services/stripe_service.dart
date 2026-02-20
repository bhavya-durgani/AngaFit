import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../../features/cart/success_screen.dart';

class StripeService {
  Map<String, dynamic>? paymentIntent;

  // 1. MAIN FUNCTION: Triggers the whole payment flow
  Future<void> makePayment(BuildContext context, double amount) async {
    try {
      // Create a Payment Intent on Stripe Servers
      paymentIntent = await createPaymentIntent(amount.toStringAsFixed(0), 'INR');

      // Initialize the Payment Sheet UI
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'AngaFit AR Store',
        ),
      );

      // Show the Payment Sheet to the user
      await displayPaymentSheet(context);
    } catch (e) {
      debugPrint("Stripe Initialization Error: $e");
    }
  }

  // 2. DISPLAY: Opens the bottom sheet for card entry
  displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // SUCCESS REDIRECTION
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
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': '${amount}00', // Amount in paise (₹1 = 100 paise)
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ssk_test_51T2sfBPAvUbK5SvGvFpgYxREzlxe6uJ8EvY9Op8bow7qKURcB3MHxwCMp1eudweTNsvq91UtMskx3aPodm9bMm5V00MdXiALTY', // Replace with your sk_test_...
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Error creating intent: ${err.toString()}');
    }
  }
}
