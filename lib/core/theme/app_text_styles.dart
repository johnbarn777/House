import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headers - Carter One (Playful Cartoon Style)
  static TextStyle get title => GoogleFonts.carterOne(
    fontSize: 28,
    color: AppColors.textInk,
    letterSpacing: 1.0,
    shadows: [
      Shadow(
        offset: const Offset(1, 1),
        blurRadius: 0,
        color: Colors.black.withValues(alpha: 0.1),
      ),
    ],
  );

  static TextStyle get moduleTitle => GoogleFonts.carterOne(
    fontSize: 22,
    color: AppColors.textInk,
    letterSpacing: 0.5,
  );

  static TextStyle get cardTitle => GoogleFonts.carterOne(
    fontSize: 20,
    color: AppColors.textLight, // Usually on wood
    shadows: [
      const Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black38),
    ],
  );

  // Body - Nunito (Rounded, Friendly, Readable)
  static TextStyle get body => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold for cartoon feel
    color: AppColors.textInk,
  );

  static TextStyle get bodyLight => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.textParchment,
  );

  static TextStyle get button =>
      GoogleFonts.carterOne(fontSize: 18, color: AppColors.textInk);

  static TextStyle get error => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.error,
  );
}
