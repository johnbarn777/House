import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String id;
  final String houseName;
  final List<String> members;

  House({required this.id, required this.houseName, required this.members});

  factory House.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return House(
      id: doc.id,
      houseName: data['houseName'] ?? '',
      members: List<String>.from(data['members'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'houseName': houseName, 'members': members};
  }
}
