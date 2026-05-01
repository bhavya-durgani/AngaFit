import 'package:flutter/material.dart';  
// Imports Flutter material UI components

import 'package:google_fonts/google_fonts.dart';  
// Imports Google Fonts package to use custom fonts

import '../constants/app_colors.dart';  
// Imports your custom color class

class AppTheme {  
  // Class used to define overall app theme (UI styling)

  static ThemeData get lightTheme => ThemeData(  
    // Defines a light theme for the app

    scaffoldBackgroundColor: AppColors.background,  
    // Sets background color for all screens

    primaryColor: AppColors.primaryRed,  
    // Sets main theme color (used across app)

    textTheme: GoogleFonts.metrophobicTextTheme(),  
    // Applies "Metrophobic" font to all text in app

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,  
      // AppBar background color

      elevation: 0,  
      // Removes shadow under AppBar

      centerTitle: true  
      // Centers title text in AppBar
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      // Defines style for all ElevatedButtons in app

      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,  
        // Button background color

        foregroundColor: Colors.white,  
        // Button text color

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)  
          // Makes button corners rounded
        )
      )
    ),
  );
}
