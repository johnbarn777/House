import 'package:cloud_firestore/cloud_firestore.dart';

enum FridgeCategory {
  produce,
  dairy,
  meat,
  pantry,
  beverages,
  frozen,
  household,
  other,
}

enum StockStatus { inStock, low, outOfStock }

enum StorageLocation { fridge, freezer, pantry }

class FridgeItem {
  final String id;
  final String name;
  final FridgeCategory category;
  final double quantity;
  final String unit;
  final StockStatus status;
  final bool isOnShoppingList;
  final DateTime? expirationDate;
  final StorageLocation location;
  final String houseId;

  // Future-proofing fields
  final DateTime? lastPurchased;
  final int? typicalLifespanDays;
  final bool autoRestock;

  FridgeItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1.0,
    this.unit = 'units',
    this.status = StockStatus.inStock,
    this.isOnShoppingList = false,
    this.expirationDate,
    this.location = StorageLocation.fridge,
    required this.houseId,
    this.lastPurchased,
    this.typicalLifespanDays,
    this.autoRestock = false,
  });

  factory FridgeItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FridgeItem(
      id: doc.id,
      name: data['name'] ?? '',
      category: FridgeCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => FridgeCategory.other,
      ),
      quantity: (data['quantity'] ?? 1.0).toDouble(),
      unit: data['unit'] ?? 'units',
      status: StockStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => StockStatus.inStock,
      ),
      isOnShoppingList: data['isOnShoppingList'] ?? false,
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null,
      location: StorageLocation.values.firstWhere(
        (e) => e.name == data['location'],
        orElse: () => StorageLocation.fridge,
      ),
      houseId: data['houseId'] ?? '',
      lastPurchased: data['lastPurchased'] != null
          ? (data['lastPurchased'] as Timestamp).toDate()
          : null,
      typicalLifespanDays: data['typicalLifespanDays'],
      autoRestock: data['autoRestock'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'unit': unit,
      'status': status.name,
      'isOnShoppingList': isOnShoppingList,
      'expirationDate': expirationDate != null
          ? Timestamp.fromDate(expirationDate!)
          : null,
      'location': location.name,
      'houseId': houseId,
      'lastPurchased': lastPurchased != null
          ? Timestamp.fromDate(lastPurchased!)
          : null,
      'typicalLifespanDays': typicalLifespanDays,
      'autoRestock': autoRestock,
    };
  }

  FridgeItem copyWith({
    String? id,
    String? name,
    FridgeCategory? category,
    double? quantity,
    String? unit,
    StockStatus? status,
    bool? isOnShoppingList,
    DateTime? expirationDate,
    StorageLocation? location,
    String? houseId,
    DateTime? lastPurchased,
    int? typicalLifespanDays,
    bool? autoRestock,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      isOnShoppingList: isOnShoppingList ?? this.isOnShoppingList,
      expirationDate: expirationDate ?? this.expirationDate,
      location: location ?? this.location,
      houseId: houseId ?? this.houseId,
      lastPurchased: lastPurchased ?? this.lastPurchased,
      typicalLifespanDays: typicalLifespanDays ?? this.typicalLifespanDays,
      autoRestock: autoRestock ?? this.autoRestock,
    );
  }
}
