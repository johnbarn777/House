import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chore.dart';

class ChoresRepository {
  final FirebaseFirestore _firestore;

  ChoresRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Chore>> getChoresForHouse(String houseId) {
    return _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .orderBy('nextDueAt')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Chore.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addChore(String houseId, Chore chore) async {
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .add(chore.toMap());
  }

  Future<void> updateChore(String houseId, Chore chore) async {
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .doc(chore.id)
        .update(chore.toMap());
  }

  Future<void> deleteChore(String houseId, String choreId) async {
    await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .doc(choreId)
        .delete();
  }

  Future<void> autoAssignChores(String houseId, List<String> memberIds) async {
    if (memberIds.isEmpty) return;

    final choresSnapshot = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .where('assignedTo', isNull: true)
        .get();

    final batch = _firestore.batch();

    for (var doc in choresSnapshot.docs) {
      final randomMember = (memberIds..shuffle()).first;
      batch.update(doc.reference, {'assignedTo': randomMember});
    }

    await batch.commit();
  }

  Future<void> unassignAllChores(String houseId) async {
    final choresSnapshot = await _firestore
        .collection('houses')
        .doc(houseId)
        .collection('chores')
        .where('assignedTo', isNull: false)
        .get();

    final batch = _firestore.batch();

    for (var doc in choresSnapshot.docs) {
      batch.update(doc.reference, {'assignedTo': null});
    }

    await batch.commit();
  }
}
