import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryRed,
    textTheme: GoogleFonts.metrophobicTextTheme(),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.background, elevation: 0, centerTitle: true),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
        )
    ),
  );
}
