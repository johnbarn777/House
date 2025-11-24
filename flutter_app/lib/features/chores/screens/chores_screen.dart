import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chores_provider.dart';
import '../../../core/providers/houses_provider.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/chore_list_item.dart';
import 'add_edit_chore_screen.dart';

class ChoresScreen extends ConsumerWidget {
  const ChoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choresAsync = ref.watch(choresProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Chores', style: AppTextStyles.cardTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final houseId = ref.read(currentHouseIdProvider);
              if (houseId == null) return;

              if (value == 'auto_assign') {
                final house = await ref.read(currentHouseProvider.future);
                if (house != null && house.members.isNotEmpty) {
                  await ref
                      .read(choresRepositoryProvider)
                      .autoAssignChores(houseId, house.members);
                }
              } else if (value == 'unassign_all') {
                await ref
                    .read(choresRepositoryProvider)
                    .unassignAllChores(houseId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'auto_assign',
                child: Text('Auto-Assign Chores'),
              ),
              const PopupMenuItem(
                value: 'unassign_all',
                child: Text('Unassign All'),
              ),
            ],
          ),
        ],
      ),
      body: choresAsync.when(
        data: (chores) {
          if (chores.isEmpty) {
            return Center(
              child: Text(
                'No chores found. Add one to get started!',
                style: AppTextStyles.bodySecondary,
              ),
            );
          }

          final myChores = chores
              .where((c) => c.assignedTo == currentUser?.uid)
              .toList();
          final otherChores = chores
              .where((c) => c.assignedTo != currentUser?.uid)
              .toList();

          void onComplete(chore) async {
            final houseId = ref.read(currentHouseIdProvider);
            if (houseId == null) return;

            final nextDue = app_date_utils.DateUtils.computeNextDue(
              chore.nextDueAt,
              chore.schedule.frequency,
              chore.schedule.interval,
            );

            final updatedChore = chore.copyWith(nextDueAt: nextDue);
            await ref
                .read(choresRepositoryProvider)
                .updateChore(houseId, updatedChore);
          }

          return ListView(
            children: [
              if (myChores.isNotEmpty) ...[
                _buildSectionHeader(context, 'My Chores'),
                ...myChores.map(
                  (chore) => ChoreListItem(
                    chore: chore,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditChoreScreen(chore: chore),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditChoreScreen(chore: chore),
                        ),
                      );
                    },
                    onDelete: () async {
                      final houseId = ref.read(currentHouseIdProvider);
                      if (houseId != null) {
                        await ref
                            .read(choresRepositoryProvider)
                            .deleteChore(houseId, chore.id);
                      }
                    },
                    onComplete: () => onComplete(chore),
                  ),
                ),
              ],
              if (otherChores.isNotEmpty) ...[
                _buildSectionHeader(context, 'Other Chores'),
                ...otherChores.map(
                  (chore) => ChoreListItem(
                    chore: chore,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditChoreScreen(chore: chore),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditChoreScreen(chore: chore),
                        ),
                      );
                    },
                    onDelete: () async {
                      final houseId = ref.read(currentHouseIdProvider);
                      if (houseId != null) {
                        await ref
                            .read(choresRepositoryProvider)
                            .deleteChore(houseId, chore.id);
                      }
                    },
                    onComplete: () => onComplete(chore),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditChoreScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
