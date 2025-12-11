import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'plank_container.dart';

class CommandDock extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CommandDock({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      child: PlankContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDockItem(context, 0, Icons.anchor, 'DECK'),
            _buildDockItem(context, 1, Icons.assignment_outlined, 'DUTIES'),
            _buildDockItem(context, 2, Icons.local_dining, 'GALLEY'),
            _buildDockItem(context, 3, Icons.map_outlined, 'HELM'),
          ],
        ),
      ),
    );
  }

  Widget _buildDockItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = selectedIndex == index;
    // Gold for selected, Parchment/Light for unselected
    final color = isSelected ? AppColors.secondaryGold : AppColors.textLight;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primarySea.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.secondaryGold.withValues(alpha: 0.5),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
              shadows: isSelected
                  ? [
                      Shadow(
                        color: AppColors.secondaryGold.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: null, // Reset to use styles from AppTextStyles
              ),
            ),
          ],
        ),
      ),
    );
  }
}
