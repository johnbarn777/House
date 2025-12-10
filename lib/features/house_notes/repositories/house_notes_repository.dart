import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/house_note.dart';

class HouseNotesRepository {
  final FirebaseFirestore _firestore;

  HouseNotesRepository(this._firestore);

  Stream<List<HouseNote>> getNotes(String houseId) {
    return _firestore
        .collection('house_notes')
        .where('houseId', isEqualTo: houseId)
        .snapshots()
        .map((snapshot) {
          final notes = snapshot.docs.map((doc) {
            try {
              return HouseNote.fromMap(doc.data(), doc.id);
            } catch (e) {
              rethrow;
            }
          }).toList();

          // Sort client-side: Pinned first, then CreatedAt descending
          notes.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });

          return notes;
        });
  }

  Future<void> addNote(HouseNote note) async {
    // We don't want to include 'id' in the map if it's empty or null,
    // but HouseNote.toMap() includes it. Firestore add() generates an ID.
    // So we'll use a modified map or let Firestore generate it and ignore the 'id' field in the map if it's not needed by logic.
    // Best practice: Let firestore generate ID, then if we need it in the doc, we update it, or just rely on doc.id.
    // HouseNote.toMap() puts 'id' in the map.

    final data = note.toMap();
    data.remove('id'); // Remove empty ID so it doesn't pollute data

    await _firestore.collection('house_notes').add(data);
  }

  Future<void> updateNote(HouseNote note) async {
    final data = note.toMap();
    data.remove('id');
    await _firestore.collection('house_notes').doc(note.id).update(data);
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('house_notes').doc(noteId).delete();
  }
}
