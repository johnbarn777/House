import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    await _firestore.collection('chores').doc(choreId).update({
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
