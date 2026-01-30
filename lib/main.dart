import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/main_nav_wrapper.dart';
void main() {
  runApp(const AngaFit());
}
class AngaFit extends StatelessWidget {
  const AngaFit({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AR Style Hub',
      theme: AppTheme.lightTheme,
      home: MainNavWrapper(),
    );
  }
}