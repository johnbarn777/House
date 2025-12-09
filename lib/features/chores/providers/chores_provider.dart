import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/houses_provider.dart';
import '../models/chore.dart';
import '../repositories/chores_repository.dart';

// Provides the list of chores for the current house
final choresProvider = StreamProvider<List<Chore>>((ref) {
  final houseId = ref.watch(currentHouseIdProvider);

  if (houseId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(choresRepositoryProvider);
  return repository.getChores(houseId);
});

class ChoreController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<void> addChore(Chore chore) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(choresRepositoryProvider).addChore(chore),
    );
  }

  Future<void> updateChore(Chore chore) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(choresRepositoryProvider).updateChore(chore),
    );
  }

  Future<void> deleteChore(String choreId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(choresRepositoryProvider).deleteChore(choreId),
    );
  }

  Future<void> completeChore(
    String choreId,
    String userId, {
    String? photoUrl,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(choresRepositoryProvider)
          .completeChore(choreId, userId, photoUrl: photoUrl, note: note),
    );
  }

  Future<void> uncompleteChore(String choreId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(choresRepositoryProvider).uncompleteChore(choreId),
    );
  }

  Future<void> snoozeChore(
    String choreId,
    DateTime newDueDate,
    String reason,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(choresRepositoryProvider)
          .snoozeChore(choreId, newDueDate, reason),
    );
  }
}

final choreControllerProvider = AsyncNotifierProvider<ChoreController, void>(
  ChoreController.new,
);
