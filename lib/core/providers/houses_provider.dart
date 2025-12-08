import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/house.dart';
import '../services/houses_repository.dart';
import 'auth_provider.dart';

final housesRepositoryProvider = Provider<HousesRepository>((ref) {
  return HousesRepository();
});

final housesProvider = StreamProvider<List<House>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(housesRepositoryProvider).getHousesForUser(user.uid);
});

class CurrentHouseIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setHouseId(String? id) {
    state = id;
  }
}

final currentHouseIdProvider =
    NotifierProvider<CurrentHouseIdNotifier, String?>(
      () => CurrentHouseIdNotifier(),
    );

final currentHouseProvider = FutureProvider<House?>((ref) async {
  final houseId = ref.watch(currentHouseIdProvider);
  if (houseId == null) return null;

  return ref.watch(housesRepositoryProvider).getHouse(houseId);
});
