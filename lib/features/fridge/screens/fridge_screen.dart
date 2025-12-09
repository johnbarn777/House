import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/houses_provider.dart';
import '../providers/fridge_provider.dart';
import '../widgets/fridge_item_tile.dart';
import '../models/fridge_item.dart';

class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final houseId = ref.watch(currentHouseIdProvider);
    final inventory = ref.watch(inventoryProvider);
    final shoppingList = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridge & Pantry'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Inventory', icon: Icon(Icons.kitchen)),
            Tab(text: 'Shopping List', icon: Icon(Icons.shopping_cart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Inventory Tab
          houseId == null
              ? const Center(child: CircularProgressIndicator())
              : inventory.isEmpty
              ? const Center(
                  child: Text('Your fridge is empty! Add items below.'),
                )
              : ListView.builder(
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return FridgeItemTile(
                      item: item,
                      onTap: () {
                        // Navigate to Edit Screen
                        context.push('/fridge/edit', extra: item);
                      },
                      onStatusChanged: (newStatus) {
                        final updatedItem = item.copyWith(status: newStatus);
                        // If marking as Out of Stock, maybe auto-add to shopping list?
                        // For now, just update status.
                        ref
                            .read(fridgeRepositoryProvider)
                            .updateFridgeItem(houseId, updatedItem);
                      },
                      onAddToShoppingList: () {
                        final updatedItem = item.copyWith(
                          isOnShoppingList: true,
                        );
                        ref
                            .read(fridgeRepositoryProvider)
                            .updateFridgeItem(houseId, updatedItem);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${item.name} to Shopping List',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          // Shopping List Tab
          houseId == null
              ? const Center(child: CircularProgressIndicator())
              : shoppingList.isEmpty
              ? const Center(child: Text('Shopping list is empty!'))
              : ListView.builder(
                  itemCount: shoppingList.length,
                  itemBuilder: (context, index) {
                    final item = shoppingList[index];
                    return ListTile(
                      leading: Checkbox(
                        value:
                            false, // Always false until checked, then it disappears/moves
                        onChanged: (value) {
                          if (value == true) {
                            // Mark as bought: In Stock and removed from list
                            final updatedItem = item.copyWith(
                              status: StockStatus.inStock,
                              isOnShoppingList: false,
                              lastPurchased: DateTime.now(),
                            );
                            ref
                                .read(fridgeRepositoryProvider)
                                .updateFridgeItem(houseId, updatedItem);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Bought ${item.name}!')),
                            );
                          }
                        },
                      ),
                      title: Text(item.name),
                      subtitle: Text('${item.quantity} ${item.unit}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          // Remove from shopping list without buying (keep current status)
                          final updatedItem = item.copyWith(
                            isOnShoppingList: false,
                          );
                          ref
                              .read(fridgeRepositoryProvider)
                              .updateFridgeItem(houseId, updatedItem);
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Screen
          context.push('/fridge/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
