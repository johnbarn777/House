import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        return Colors.green;
      case StockStatus.low:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(item.status),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit} • ${item.category.name.toUpperCase()}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: PopupMenuButton<dynamic>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value is StockStatus && onStatusChanged != null) {
              onStatusChanged!(value);
            } else if (value == 'shopping_list' &&
                onAddToShoppingList != null) {
              onAddToShoppingList!();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: StockStatus.inStock,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('In Stock'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: StockStatus.low,
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Low Stock'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: StockStatus.outOfStock,
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Out of Stock'),
                ],
              ),
            ),
            if (!item.isOnShoppingList)
              const PopupMenuItem(
                value: 'shopping_list',
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart_checkout, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Add to Shopping List'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
