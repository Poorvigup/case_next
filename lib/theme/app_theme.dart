// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6A1B29); // Judicial Maroon
  static const Color accentColor = Color(0xFFC09553); // Gilded Bronze
  static const Color backgroundColor = Color(0xFFFDFBF7); // Parchment White
  static const Color primaryTextColor = Color(0xFF333333);

  static ThemeData get theme {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 4, // Add a bit of shadow for depth
        shadowColor: Colors.black.withOpacity(0.2),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryTextColor),
        headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryTextColor, fontSize: 24),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor),
        bodyLarge: const TextStyle(color: primaryTextColor, height: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        floatingLabelStyle: const TextStyle(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}