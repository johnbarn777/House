import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/house.dart';

class HousesRepository {
  final FirebaseFirestore _firestore;

  HousesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<House>> getHousesForUser(String userId) {
    return _firestore
        .collection('houses')
        .where('members', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => House.fromFirestore(doc)).toList(),
        );
  }

  Future<House?> getHouse(String houseId) async {
    final doc = await _firestore.collection('houses').doc(houseId).get();
    if (!doc.exists) return null;
    return House.fromFirestore(doc);
  }
}
