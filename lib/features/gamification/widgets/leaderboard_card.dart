import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/users_repository.dart';
import '../../../core/providers/houses_provider.dart';

// Provider to fetch profiles for the current house members
final houseMembersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final houseId = ref.watch(currentHouseIdProvider);
  if (houseId == null) return [];

  // We need to fetch the House object to get member IDs
  // (Assuming 'housesProvider' returns list of houses, we find the one matching ID)
  final houses = await ref.watch(housesProvider.future);
  final house = houses.firstWhere(
    (h) => h.id == houseId,
    orElse: () => houses.first,
  ); // Fallback

  return ref.read(usersRepositoryProvider).getUsers(house.members);
});

class LeaderboardCard extends ConsumerWidget {
  const LeaderboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(houseMembersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "WANTED POSTERS (Leaderboard)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Carter One',
              ),
            ),
            const SizedBox(height: 10),
            membersAsync.when(
              data: (users) {
                // Sort by points (descending)
                final sortedUsers = users.toList()
                  ..sort(
                    (a, b) => b.lifetimePoints.compareTo(a.lifetimePoints),
                  );

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedUsers.length,
                  itemBuilder: (context, index) {
                    final user = sortedUsers[index];
                    final isFirst = index == 0;
                    final isLast =
                        index == sortedUsers.length - 1 &&
                        sortedUsers.length > 1;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Text(user.displayName?[0] ?? '?')
                            : null,
                      ),
                      title: Text(user.displayName ?? 'Unknown Pirate'),
                      subtitle: Text("${user.lifetimePoints} XP"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isFirst)
                            const Text("👑", style: TextStyle(fontSize: 24)),
                          if (isLast)
                            const Text(
                              "🍕",
                              style: TextStyle(fontSize: 24),
                            ), // Pizza penalty!
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text("Error loading crew: $e"),
            ),
          ],
        ),
      ),
    );
  }
}
