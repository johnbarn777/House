import 'package:cloud_firestore/cloud_firestore.dart';

enum RepeatSchedule { none, daily, weekly, monthly }

class SnoozeRecord {
  final DateTime snoozeDate;
  final DateTime originalDueDate;
  final DateTime newDueDate;
  final String reason;

  const SnoozeRecord({
    required this.snoozeDate,
    required this.originalDueDate,
    required this.newDueDate,
    required this.reason,
  });

  factory SnoozeRecord.fromMap(Map<String, dynamic> map) {
    return SnoozeRecord(
      snoozeDate: (map['snoozeDate'] as Timestamp).toDate(),
      originalDueDate: (map['originalDueDate'] as Timestamp).toDate(),
      newDueDate: (map['newDueDate'] as Timestamp).toDate(),
      reason: map['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'snoozeDate': Timestamp.fromDate(snoozeDate),
      'originalDueDate': Timestamp.fromDate(originalDueDate),
      'newDueDate': Timestamp.fromDate(newDueDate),
      'reason': reason,
    };
  }
}

class Chore {
  final String id;
  final String houseId;
  final String title;
  final String description;
  final List<String> assignedToIds;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? completedBy;
  final DateTime? completedAt;
  final String? photoUrl;
  final String? completionNote;
  final RepeatSchedule repeatSchedule;
  final List<SnoozeRecord> snoozeHistory;

  const Chore({
    required this.id,
    required this.houseId,
    required this.title,
    this.description = '',
    this.assignedToIds = const [],
    this.dueDate,
    this.isCompleted = false,
    this.completedBy,
    this.completedAt,
    this.photoUrl,
    this.completionNote,
    this.repeatSchedule = RepeatSchedule.none,
    this.snoozeHistory = const [],
  });

  factory Chore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chore(
      id: doc.id,
      houseId: data['houseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedToIds: List<String>.from(data['assignedToIds'] ?? []),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'] ?? false,
      completedBy: data['completedBy'],
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      photoUrl: data['photoUrl'],
      completionNote: data['completionNote'],
      repeatSchedule: RepeatSchedule.values.firstWhere(
        (e) => e.name == (data['repeatSchedule'] ?? 'none'),
        orElse: () => RepeatSchedule.none,
      ),
      snoozeHistory:
          (data['snoozeHistory'] as List<dynamic>?)
              ?.map((e) => SnoozeRecord.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'houseId': houseId,
      'title': title,
      'description': description,
      'assignedToIds': assignedToIds,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'completedBy': completedBy,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'photoUrl': photoUrl,
      'completionNote': completionNote,
      'repeatSchedule': repeatSchedule.name,
      'snoozeHistory': snoozeHistory.map((e) => e.toMap()).toList(),
    };
  }

  Chore copyWith({
    String? id,
    String? houseId,
    String? title,
    String? description,
    List<String>? assignedToIds,
    DateTime? dueDate,
    bool? isCompleted,
    String? completedBy,
    DateTime? completedAt,
    String? photoUrl,
    String? completionNote,
    RepeatSchedule? repeatSchedule,
    List<SnoozeRecord>? snoozeHistory,
  }) {
    return Chore(
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToIds: assignedToIds ?? this.assignedToIds,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
      photoUrl: photoUrl ?? this.photoUrl,
      completionNote: completionNote ?? this.completionNote,
      repeatSchedule: repeatSchedule ?? this.repeatSchedule,
      snoozeHistory: snoozeHistory ?? this.snoozeHistory,
    );
  }
}
