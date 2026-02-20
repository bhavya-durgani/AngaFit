import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/cart_provider.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  // 3. Initialize Stripe (Replace with your actual pk_test_... key)
  Stripe.publishableKey = "pk_test_51T2sfBPAvUbK5SvGoyq41XU0y8oB6IiQde5J4Z3Ffgu4MIICG67WJbhUhMgL2s3pZebmmcD1TkhpQNm2ecOgU8TL00mrbcknK8";
  try {
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint("Stripe Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const AngaFit(),
    ),
  );
}

class AngaFit extends StatelessWidget {
  const AngaFit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AngaFit',
      theme: AppTheme.lightTheme,
      // The app starts with the Splash Screen to handle navigation logic
      home: const SplashScreen(),
    );
  }
}
