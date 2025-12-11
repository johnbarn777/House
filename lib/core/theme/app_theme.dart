import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primarySea,
        surface: AppColors.backgroundParchment,
        onSurface: AppColors.textInk,
        error: AppColors.accentRed,
        secondary: AppColors.secondaryGold,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundParchment,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.rye(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textInk,
          letterSpacing: 1.0,
        ),
        iconTheme: const IconThemeData(color: AppColors.textInk),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.backgroundParchment,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(
            color: AppColors.textInk,
            width: 1,
            style: BorderStyle.none,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.rye(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textInk,
        ),
        titleLarge: GoogleFonts.rye(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textInk,
        ),
        titleMedium: GoogleFonts.rye(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textInk,
        ),
        bodyLarge: GoogleFonts.crimsonText(
          // Crimson Text for body
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.textInk,
        ),
        bodyMedium: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textInk,
        ),
        bodySmall: GoogleFonts.crimsonText(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textParchment,
        ),
        labelLarge: GoogleFonts.rye(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textInk,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundParchment,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.textInk),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.textInk),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primarySea, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
        ),
        labelStyle: GoogleFonts.crimsonText(
          fontSize: 16,
          color: AppColors.textParchment,
        ),
        hintStyle: GoogleFonts.crimsonText(
          fontSize: 16,
          color: AppColors.textParchment.withValues(alpha: 0.5),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySea,
          foregroundColor: AppColors.secondaryGold,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.rye(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textInk,
          textStyle: GoogleFonts.rye(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.textLight,
        elevation: 8,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWood,
        selectedItemColor: AppColors.secondaryGold,
        unselectedItemColor: AppColors.textLight.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.rye(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.rye(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundParchment,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.textInk, width: 1),
        ),
        titleTextStyle: GoogleFonts.rye(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textInk,
        ),
        contentTextStyle: GoogleFonts.crimsonText(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.textInk,
        ),
      ),
    );
  }
}
