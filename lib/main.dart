import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() => runApp(const AngaFit());

class AngaFit extends StatelessWidget {
  const AngaFit({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen()
  );
}
