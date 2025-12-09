import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chores_provider.dart';
import '../widgets/chore_list_item.dart';
import '../widgets/chore_completion_dialog.dart';
import '../widgets/snooze_chore_dialog.dart';
import 'add_edit_chore_screen.dart';

class ChoresScreen extends ConsumerWidget {
  const ChoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choresAsyncValue = ref.watch(choresProvider);
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Chores')),
      body: choresAsyncValue.when(
        data: (chores) {
          if (chores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No chores found.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          }

          // Sort chores: Overdue first, then by date
          // (Already sorted by date in repo, but client side sort can ensure completed are at bottom)
          final activeChores = chores.where((c) => !c.isCompleted).toList();
          final completedChores = chores.where((c) => c.isCompleted).toList();

          final sortedActive = [
            ...activeChores,
          ]; // Repo sort is likely strictly by date, we might want overdue first logic if not present.
          // For now rely on repo sort.

          return ListView(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            children: [
              if (sortedActive.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'To Do',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...sortedActive.map(
                  (chore) => ChoreListItem(
                    chore: chore,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditChoreScreen(chore: chore),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditChoreScreen(chore: chore),
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Chore?'),
                          content: const Text('This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref
                            .read(choreControllerProvider.notifier)
                            .deleteChore(chore.id);
                      }
                    },
                    onSnooze: () async {
                      if (chore.dueDate == null) return;

                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (_) =>
                            SnoozeChoreDialog(currentDueDate: chore.dueDate!),
                      );

                      if (result != null) {
                        await ref
                            .read(choreControllerProvider.notifier)
                            .snoozeChore(
                              chore.id,
                              result['date'] as DateTime,
                              result['reason'] as String,
                            );
                      }
                    },
                    onCompletionChanged: (value) async {
                      if (currentUser == null || value != true) return;

                      final result = await showDialog<Map<String, String?>>(
                        context: context,
                        builder: (_) =>
                            ChoreCompletionDialog(choreId: chore.id),
                      );

                      if (result != null) {
                        await ref
                            .read(choreControllerProvider.notifier)
                            .completeChore(
                              chore.id,
                              currentUser.uid,
                              photoUrl: result['photoUrl'],
                              note: result['note'],
                            );
                      }
                    },
                  ),
                ),
              ],

              if (completedChores.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...completedChores.map(
                  (chore) => ChoreListItem(
                    chore: chore,
                    onTap: () {},
                    onCompletionChanged: (value) async {
                      if (value == false) {
                        // Un-complete
                        await ref
                            .read(choreControllerProvider.notifier)
                            .uncompleteChore(chore.id);
                      }
                    },
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
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddEditChoreScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
