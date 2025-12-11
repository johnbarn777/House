import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_profile.dart';
import '../models/transaction_record.dart';

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(FirebaseFirestore.instance);
});

class GamificationService {
  final FirebaseFirestore _firestore;

  GamificationService(this._firestore);

  Future<void> awardPoints({
    required String userId,
    required int points,
    required int doubloons,
    required String reason,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final txRef = _firestore.collection('transaction_history').doc();

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final user = UserProfile.fromFirestore(userDoc);

      final updatedUser = {
        'doubloons': user.doubloons + doubloons,
        'lifetimePoints': user.lifetimePoints + points,
      };

      final txRecord = TransactionRecord(
        id: txRef.id,
        userId: userId,
        amount: doubloons,
        reason: reason,
        timestamp: DateTime.now(),
      );

      transaction.update(userRef, updatedUser);
      transaction.set(txRef, txRecord.toMap());
    });
  }

  Future<bool> purchaseItem({
    required String userId,
    required String itemId,
    required int cost,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final txRef = _firestore.collection('transaction_history').doc();

    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception("User not found");

        final user = UserProfile.fromFirestore(userDoc);
        if (user.doubloons < cost) {
          throw Exception("Insufficient funds");
        }

        final newInventory = Map<String, int>.from(user.inventory);
        newInventory[itemId] = (newInventory[itemId] ?? 0) + 1;

        transaction.update(userRef, {
          'doubloons': user.doubloons - cost,
          'inventory': newInventory,
        });

        transaction.set(
          txRef,
          TransactionRecord(
            id: txRef.id,
            userId: userId,
            amount: -cost,
            reason: "Purchased $itemId",
            timestamp: DateTime.now(),
          ).toMap(),
        );
      });
      return true;
    } catch (e) {
      // print(e); // Handle error properly in a real app
      return false;
    }
  }

  Future<bool> consumeItem({
    required String userId,
    required String itemId,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception("User not found");

        final user = UserProfile.fromFirestore(userDoc);
        final currentCount = user.inventory[itemId] ?? 0;

        if (currentCount <= 0) {
          throw Exception("Item not in inventory");
        }

        final newInventory = Map<String, int>.from(user.inventory);
        newInventory[itemId] = currentCount - 1;
        if (newInventory[itemId] == 0) {
          newInventory.remove(itemId);
        }

        transaction.update(userRef, {'inventory': newInventory});
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
