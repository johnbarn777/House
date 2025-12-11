import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PlankContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool light; // Light or dark wood

  const PlankContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: light ? AppColors.surfaceWood : AppColors.surfaceWoodDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3E2723), // Deep Brown Border
          width: 3,
        ),
        boxShadow: [
          // Cartoon Shadow (Hard edge)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // Subtle highlight on top
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
            stops: const [0.0, 0.3],
          ),
        ),
        child: child,
      ),
    );
  }
}
