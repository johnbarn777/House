import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ParchmentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ParchmentCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundParchment,
        borderRadius: BorderRadius.circular(16), // Rounded paper
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(3, 3),
            blurRadius: 0, // Hard shadow
          ),
        ],
        border: Border.all(
          color: AppColors.textParchment.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: child,
    );
  }
}
