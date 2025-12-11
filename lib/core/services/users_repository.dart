import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

class UsersRepository {
  final FirebaseFirestore _firestore;

  UsersRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Stream<UserProfile?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  Future<List<UserProfile>> getUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    // Firestore 'in' query is limited to 10 items.
    // For now, we'll just fetch individually or use 'in' if list is small.
    // A robust app would handle batching.

    // Simple implementation: fetch all individually (parallel)
    final futures = userIds.map((id) => getUserProfile(id));
    final profiles = await Future.wait(futures);
    return profiles.whereType<UserProfile>().toList();
  }

  Future<void> updateScheduleDescription(
    String userId,
    String description,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'scheduleDescription': description,
    });
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});
