import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String id;
  final String houseName;
  final List<String> members;

  final Map<String, dynamic>? activeEvent;
  final String? captainId;
  final String? bilgeRatId;

  House({
    required this.id,
    required this.houseName,
    required this.members,
    this.activeEvent,
    this.captainId,
    this.bilgeRatId,
  });

  factory House.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return House(
      id: doc.id,
      houseName: data['houseName'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      activeEvent: data['activeEvent'],
      captainId: data['captainId'],
      bilgeRatId: data['bilgeRatId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'houseName': houseName,
      'members': members,
      'activeEvent': activeEvent,
      'captainId': captainId,
      'bilgeRatId': bilgeRatId,
    };
  }
}
