import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text styles using Montserrat font family
class AppTextStyles {
  // Title styles
  static TextStyle get title => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get cardTitle => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get moduleTitle => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get houseName => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Button styles
  static TextStyle get button => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Body styles
  static TextStyle get body => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle get bodySecondary => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFBBBBBB),
  );

  static TextStyle get caption => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFBBBBBB),
  );

  static TextStyle get error => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFFF4D4D),
  );

  // Link styles
  static TextStyle get link => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFAE00FF),
  );

  static TextStyle get houseCode => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF555555),
  );
}
