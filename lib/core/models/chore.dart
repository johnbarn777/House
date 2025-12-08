import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String frequency; // 'Daily', 'Weekly', 'Bi-weekly', 'Monthly'
  final int interval; // e.g., every 1 week, every 2 weeks

  Schedule({required this.frequency, this.interval = 1});

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      frequency: map['frequency'] ?? 'Weekly',
      interval: map['interval'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {'frequency': frequency, 'interval': interval};
  }
}

class Chore {
  final String id;
  final String title;
  final String? assignedTo;
  final DateTime nextDueAt;
  final Schedule schedule;
  final String houseId;

  Chore({
    required this.id,
    required this.title,
    this.assignedTo,
    required this.nextDueAt,
    required this.schedule,
    required this.houseId,
  });

  factory Chore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chore(
      id: doc.id,
      title: data['title'] ?? '',
      assignedTo: data['assignedTo'],
      nextDueAt: (data['nextDueAt'] as Timestamp).toDate(),
      schedule: Schedule.fromMap(data['schedule'] ?? {}),
      houseId: data['houseId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'assignedTo': assignedTo,
      'nextDueAt': Timestamp.fromDate(nextDueAt),
      'schedule': schedule.toMap(),
      'houseId': houseId,
    };
  }

  Chore copyWith({
    String? id,
    String? title,
    String? assignedTo,
    DateTime? nextDueAt,
    Schedule? schedule,
    String? houseId,
  }) {
    return Chore(
      id: id ?? this.id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      schedule: schedule ?? this.schedule,
      houseId: houseId ?? this.houseId,
    );
  }
}
