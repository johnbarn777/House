import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../models/chore.dart';

final choresRepositoryProvider = Provider<ChoresRepository>((ref) {
  return ChoresRepository(FirebaseFirestore.instance);
});

class ChoresRepository {
  final FirebaseFirestore _firestore;

  ChoresRepository(this._firestore);

  Stream<List<Chore>> getChores(String houseId) {
    print('DEBUG: getChores called for houseId: $houseId');
    return _firestore
        .collection('chores')
        .where('houseId', isEqualTo: houseId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Chore.fromFirestore(doc)).toList();
        });
  }

  Future<void> addChore(Chore chore) async {
    await _firestore.collection('chores').add(chore.toMap());
  }

  Future<void> updateChore(Chore chore) async {
    await _firestore.collection('chores').doc(chore.id).update(chore.toMap());
  }

  Future<void> deleteChore(String choreId) async {
    await _firestore.collection('chores').doc(choreId).delete();
  }

  Future<void> completeChore(
    String choreId,
    String userId, {
    String? photoUrl,
    String? note,
  }) async {
    final docRef = _firestore.collection('chores').doc(choreId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final chore = Chore.fromFirestore(docSnapshot);

      // Handle Repeating Chores
      if (chore.repeatSchedule != RepeatSchedule.none &&
          chore.dueDate != null) {
        // Calculate next due date
        // Using interval 1 for simplicity for now as per plan (Weekly = +7 days)
        // If we support "Every 2 Weeks", we'd need an interval field content.
        // For now assuming interval is 1 for the enum types.
        final nextDueDate = app_date_utils.DateUtils.computeNextDue(
          chore.dueDate!,
          chore.repeatSchedule.name,
          1, // interval
        );

        final newChore = chore.copyWith(
          id: '', // Empty ID to create new
          dueDate: nextDueDate,
          isCompleted: false,
          completedBy: null,
          completedAt: null,
          photoUrl: null,
          completionNote: null,
          // Keep assignments and repeat schedule
        );

        await addChore(newChore);
      }
    }

    await docRef.update({
      'isCompleted': true,
      'completedBy': userId,
      'completedAt': Timestamp.now(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (note != null) 'completionNote': note,
    });
  }

  Future<void> uncompleteChore(String choreId) async {
    await _firestore.collection('chores').doc(choreId).update({
      'isCompleted': false,
      'completedBy': FieldValue.delete(),
      'completedAt': FieldValue.delete(),
      'photoUrl': FieldValue.delete(),
      'completionNote': FieldValue.delete(),
    });
  }
}
