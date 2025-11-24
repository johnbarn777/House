import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'displayName': displayName, 'photoURL': photoURL};
  }
}
