import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/houses_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/parchment_card.dart';
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
      backgroundColor: AppColors.backgroundParchment,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundParchment,
                    const Color(0xFFE0D0B0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Tab Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWood,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.secondaryGold,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: AppColors.secondaryGold.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.secondaryGold),
                    ),
                    labelColor: AppColors.secondaryGold,
                    unselectedLabelColor: AppColors.textLight.withValues(
                      alpha: 0.5,
                    ),
                    labelStyle: AppTextStyles.button,
                    tabs: const [
                      Tab(
                        text: 'CARGO',
                        icon: Icon(Icons.inventory_2),
                      ), // Crate icon
                      Tab(
                        text: 'PROVISIONS',
                        icon: Icon(Icons.list_alt),
                      ), // List icon
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Inventory Tab
                      _buildInventoryList(houseId, inventory),

                      // Shopping List Tab
                      _buildShoppingList(houseId, shoppingList),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to Add Screen
            context.push('/fridge/add');
          },
          backgroundColor: AppColors.primarySea,
          child: const Icon(Icons.add, color: AppColors.secondaryGold),
        ),
      ),
    );
  }

  Widget _buildInventoryList(String? houseId, List<FridgeItem> inventory) {
    if (houseId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textInk),
      );
    }
    if (inventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textInk.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'HOLD EMPTY',
              style: AppTextStyles.moduleTitle.copyWith(
                color: AppColors.textInk,
              ),
            ),
            Text(
              'Stock up before we set sail!',
              style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: inventory.length,
      itemBuilder: (context, index) {
        final item = inventory[index];
        return FridgeItemTile(
          item: item,
          onTap: () {
            context.push('/fridge/edit', extra: item);
          },
          onStatusChanged: (newStatus) {
            final updatedItem = item.copyWith(status: newStatus);
            ref
                .read(fridgeRepositoryProvider)
                .updateFridgeItem(houseId, updatedItem);
          },
          onAddToShoppingList: () {
            final updatedItem = item.copyWith(isOnShoppingList: true);
            ref
                .read(fridgeRepositoryProvider)
                .updateFridgeItem(houseId, updatedItem);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.surfaceWood,
                content: Text(
                  'Marked ${item.name} for provisions',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.secondaryGold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShoppingList(String? houseId, List<FridgeItem> shoppingList) {
    if (houseId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textInk),
      );
    }
    if (shoppingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: AppColors.textInk.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'WELL PROVISIONED',
              style: AppTextStyles.moduleTitle.copyWith(
                color: AppColors.textInk,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: shoppingList.length,
      itemBuilder: (context, index) {
        final item = shoppingList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ParchmentCard(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: false,
                  onChanged: (value) {
                    if (value == true) {
                      // Logic to move back to inventory
                      final updatedItem = item.copyWith(
                        status: StockStatus.inStock,
                        isOnShoppingList: false,
                        lastPurchased: DateTime.now(),
                      );
                      ref
                          .read(fridgeRepositoryProvider)
                          .updateFridgeItem(houseId, updatedItem);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceWood,
                          content: Text(
                            'Acquired ${item.name}!',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  activeColor: AppColors.primarySea,
                  checkColor: AppColors.secondaryGold,
                  side: const BorderSide(color: AppColors.textInk),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              title: Text(item.name, style: AppTextStyles.body),
              subtitle: Text(
                '${item.quantity} ${item.unit}',
                style: AppTextStyles.caption,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.error,
                ),
                onPressed: () {
                  final updatedItem = item.copyWith(isOnShoppingList: false);
                  ref
                      .read(fridgeRepositoryProvider)
                      .updateFridgeItem(houseId, updatedItem);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
