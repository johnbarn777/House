import 'package:cloud_firestore/cloud_firestore.dart';

class WeekCycle {
  final String id; // e.g. "2024-W12"
  final String houseId;
  final String captainId;
  final String bilgeRatId;
  final Map<String, int> leaderboardSnapshot;
  final DateTime startDate;
  final DateTime endDate;

  const WeekCycle({
    required this.id,
    required this.houseId,
    required this.captainId,
    required this.bilgeRatId,
    required this.leaderboardSnapshot,
    required this.startDate,
    required this.endDate,
  });

  factory WeekCycle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeekCycle(
      id: doc.id,
      houseId: data['houseId'] ?? '',
      captainId: data['captainId'] ?? '',
      bilgeRatId: data['bilgeRatId'] ?? '',
      leaderboardSnapshot: Map<String, int>.from(
        data['leaderboardSnapshot'] ?? {},
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'houseId': houseId,
      'captainId': captainId,
      'bilgeRatId': bilgeRatId,
      'leaderboardSnapshot': leaderboardSnapshot,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}
