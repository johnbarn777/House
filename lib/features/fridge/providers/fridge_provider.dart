import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/providers/houses_provider.dart';
import '../models/fridge_item.dart';
import '../repositories/fridge_repository.dart';

final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  return FridgeRepository(firestore: FirebaseFirestore.instance);
});

final fridgeItemsProvider = StreamProvider.autoDispose<List<FridgeItem>>((ref) {
  final houseId = ref.watch(currentHouseIdProvider);
  if (houseId == null) return Stream.value([]);

  final repository = ref.watch(fridgeRepositoryProvider);
  return repository.getFridgeItems(houseId);
});

final inventoryProvider = Provider.autoDispose<List<FridgeItem>>((ref) {
  final items = ref.watch(fridgeItemsProvider).asData?.value ?? [];
  return items.where((item) => item.status != StockStatus.outOfStock).toList();
});

final shoppingListProvider = Provider.autoDispose<List<FridgeItem>>((ref) {
  final items = ref.watch(fridgeItemsProvider).asData?.value ?? [];
  return items.where((item) => item.isOnShoppingList).toList();
});
