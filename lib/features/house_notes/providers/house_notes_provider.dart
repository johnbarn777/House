import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/houses_provider.dart';
import '../models/house_note.dart';
import '../repositories/house_notes_repository.dart';

final houseNotesRepositoryProvider = Provider<HouseNotesRepository>((ref) {
  return HouseNotesRepository(FirebaseFirestore.instance);
});

final houseNotesProvider = StreamProvider<List<HouseNote>>((ref) {
  final houseId = ref.watch(currentHouseIdProvider);

  if (houseId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(houseNotesRepositoryProvider);
  return repository.getNotes(houseId);
});

class HouseNotesController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initialization needed
  }

  Future<void> addNote(HouseNote note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(houseNotesRepositoryProvider).addNote(note);
    });
  }

  Future<void> updateNote(HouseNote note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(houseNotesRepositoryProvider).updateNote(note);
    });
  }

  Future<void> deleteNote(String noteId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(houseNotesRepositoryProvider).deleteNote(noteId);
    });
  }
}

final houseNotesControllerProvider =
    AsyncNotifierProvider<HouseNotesController, void>(HouseNotesController.new);
