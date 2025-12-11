import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/users_repository.dart';
import 'auth_provider.dart';

final currentUserProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.read(usersRepositoryProvider).getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
