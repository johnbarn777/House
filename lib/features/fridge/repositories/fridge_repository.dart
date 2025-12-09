import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fridge_item.dart';

class FridgeRepository {
  final FirebaseFirestore _firestore;

  FridgeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<FridgeItem>> getFridgeItems(String houseId) {
    return _firestore
        .collection('houses')
        .doc(houseId)
        .collection('fridge_items')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FridgeItem.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> addFridgeItem(String houseId, FridgeItem item) async {
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('fridge_items')
        .add(item.toMap());
  }

  Future<void> updateFridgeItem(String houseId, FridgeItem item) async {
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('fridge_items')
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> deleteFridgeItem(String houseId, String itemId) async {
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('fridge_items')
        .doc(itemId)
        .delete();
  }
}
