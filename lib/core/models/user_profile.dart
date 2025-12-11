import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? scheduleDescription;
  final int doubloons;
  final int lifetimePoints;
  final Map<String, int> inventory;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.scheduleDescription,
    this.doubloons = 0,
    this.lifetimePoints = 0,
    this.inventory = const {},
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      scheduleDescription: data['scheduleDescription'],
      doubloons: data['doubloons'] ?? 0,
      lifetimePoints: data['lifetimePoints'] ?? 0,
      inventory: Map<String, int>.from(data['inventory'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'scheduleDescription': scheduleDescription,
      'doubloons': doubloons,
      'lifetimePoints': lifetimePoints,
      'inventory': inventory,
    };
  }
}
