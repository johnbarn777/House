import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chore.dart';
import '../services/chores_repository.dart';
import 'houses_provider.dart';

final choresRepositoryProvider = Provider<ChoresRepository>((ref) {
  return ChoresRepository();
});

final choresProvider = StreamProvider<List<Chore>>((ref) {
  final houseId = ref.watch(currentHouseIdProvider);
  if (houseId == null) return Stream.value([]);

  return ref.watch(choresRepositoryProvider).getChoresForHouse(houseId);
});
