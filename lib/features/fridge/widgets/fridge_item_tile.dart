import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/plank_container.dart';
import '../models/fridge_item.dart';

class FridgeItemTile extends ConsumerWidget {
  final FridgeItem item;
  final VoidCallback? onTap;
  final Function(StockStatus)? onStatusChanged;
  final VoidCallback? onAddToShoppingList;

  const FridgeItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.onStatusChanged,
    this.onAddToShoppingList,
  });

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return AppColors.success;
      case StockStatus.low:
        return AppColors.warning;
      case StockStatus.outOfStock:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: PlankContainer(
          // Crate style
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Indicator (Gem/Lantern)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black54, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(
                        item.status,
                      ).withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight, // On Wood, use light text
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit} • ${item.category.name.toUpperCase()}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              if (onStatusChanged != null || onAddToShoppingList != null)
                PopupMenuButton<dynamic>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                  color: AppColors.backgroundParchment,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                    side: const BorderSide(color: AppColors.textInk),
                  ),
                  onSelected: (value) {
                    if (value is StockStatus && onStatusChanged != null) {
                      onStatusChanged!(value);
                    } else if (value == 'shopping_list' &&
                        onAddToShoppingList != null) {
                      onAddToShoppingList!();
                    }
                  },
                  itemBuilder: (context) => [
                    _buildPopupMenuItem(
                      StockStatus.inStock,
                      'Full Ration',
                      AppColors.success,
                      Icons.check_circle,
                    ),
                    _buildPopupMenuItem(
                      StockStatus.low,
                      'Rations Low',
                      AppColors.warning,
                      Icons.warning,
                    ),
                    _buildPopupMenuItem(
                      StockStatus.outOfStock,
                      'Barrels Empty',
                      AppColors.error,
                      Icons.cancel,
                    ),

                    if (!item.isOnShoppingList)
                      PopupMenuItem(
                        value: 'shopping_list',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.list_alt,
                              color: AppColors.textInk,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add to Provisions',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.textInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem _buildPopupMenuItem(
    StockStatus value,
    String text,
    Color color,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.body.copyWith(color: AppColors.textInk),
          ),
        ],
      ),
    );
  }
}
