enum NoteUrgency { info, important, urgent }

class HouseNote {
  final String id;
  final String houseId;
  final String creatorId; // ID of user who created the note
  final String title;
  final String content;
  final NoteUrgency urgency;
  final bool isPinned;
  final DateTime createdAt;

  HouseNote({
    required this.id,
    required this.houseId,
    required this.creatorId,
    required this.title,
    required this.content,
    this.urgency = NoteUrgency.info,
    this.isPinned = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'houseId': houseId,
      'creatorId': creatorId,
      'title': title,
      'content': content,
      'urgency': urgency.name,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HouseNote.fromMap(Map<String, dynamic> map, String id) {
    return HouseNote(
      id: id,
      houseId: map['houseId'] ?? '',
      creatorId: map['creatorId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      urgency: NoteUrgency.values.firstWhere(
        (e) => e.name == map['urgency'],
        orElse: () => NoteUrgency.info,
      ),
      isPinned: map['isPinned'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  HouseNote copyWith({
    String? id,
    String? houseId,
    String? creatorId,
    String? title,
    String? content,
    NoteUrgency? urgency,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return HouseNote(
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      content: content ?? this.content,
      urgency: urgency ?? this.urgency,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
