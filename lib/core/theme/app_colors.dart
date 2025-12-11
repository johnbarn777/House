import 'package:flutter/material.dart';

class AppColors {
  // Cartoon Pirate Palette
  static const primarySea = Color(0xFF0099CC); // Bright Blue Sea
  static const secondaryGold = Color(0xFFFFCC00); // Cartoon Gold
  static const accentRed = Color(0xFFFF5555); // Candy Red
  static const accentGreen = Color(0xFF66BB6A); // Parrot Green

  static const backgroundParchment = Color(0xFFFFF8E1); // Creamy Paper
  static const surfaceWood = Color(0xFFA0522D); // Sienna / Milk Chocolate
  static const surfaceWoodDark = Color(0xFF8B4513); // Saddle Brown

  // Text Colors (High Contrast)
  static const textInk = Color(
    0xFF3E2723,
  ); // Dark Brown (instead of harsh black)
  static const textParchment = Color(0xFF5D4037); // Lighter Brown
  static const textLight = Color(0xFFFFF8E1); // Cream (on dark backgrounds)

  // Functional Colors
  static const success = Color(0xFF4CAF50); // Bright Green
  static const warning = Color(0xFFFF9800); // Bright Orange
  static const error = Color(0xFFFF1744); // Bright Red
  static const info = Color(0xFF29B6F6); // Sky Blue

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [primarySea, Color(0xFF006699)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient woodGradient = LinearGradient(
    colors: [surfaceWood, surfaceWoodDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
