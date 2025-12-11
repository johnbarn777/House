import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
      backgroundColor: AppColors.backgroundParchment,
      body: Stack(
        children: [
          // Background Texture
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundParchment,
                    const Color(0xFFE0D0B0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment, color: AppColors.textInk),
                      const SizedBox(width: 8),
                      Text(
                        'DUTY ROSTER',
                        style: AppTextStyles.title.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: choresAsyncValue.when(
                    data: (chores) {
                      if (chores.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: AppColors.success.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'SHIPSHAPE',
                                style: AppTextStyles.moduleTitle.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No pending duties.',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        );
                      }

                      final activeChores = chores
                          .where((c) => !c.isCompleted)
                          .toList();
                      final completedChores = chores
                          .where((c) => c.isCompleted)
                          .toList();

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          100,
                        ), // Bottom padding for FAB/Dock
                        children: [
                          if (activeChores.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    color: AppColors.accentRed,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ACTIVE ORDERS',
                                    style: AppTextStyles.moduleTitle.copyWith(
                                      fontSize: 16,
                                      color: AppColors.accentRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...activeChores.map(
                              (chore) => _buildChoreItem(
                                context,
                                ref,
                                chore,
                                currentUser,
                              ),
                            ),
                          ],

                          if (completedChores.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    color: AppColors.textParchment,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'COMPLETED LOGS',
                                    style: AppTextStyles.moduleTitle.copyWith(
                                      fontSize: 16,
                                      color: AppColors.textParchment,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...completedChores.map(
                              (chore) => _buildChoreItem(
                                context,
                                ref,
                                chore,
                                currentUser,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textInk,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'LOG ERROR: $error',
                        style: AppTextStyles.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEditChoreScreen()),
            );
          },
          backgroundColor: AppColors.primarySea,
          child: const Icon(Icons.add, color: AppColors.secondaryGold),
        ),
      ),
    );
  }

  Widget _buildChoreItem(
    BuildContext context,
    WidgetRef ref,
    dynamic chore,
    dynamic currentUser,
  ) {
    return ChoreListItem(
      chore: chore,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddEditChoreScreen(chore: chore)),
        );
      },
      onEdit: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddEditChoreScreen(chore: chore)),
        );
      },
      onDelete: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.backgroundParchment,
            title: Text(
              'ABORT MISSION?',
              style: AppTextStyles.cardTitle.copyWith(color: AppColors.textInk),
            ),
            content: Text(
              'This action cannot be undone.',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('BELAY THAT', style: AppTextStyles.button),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'SCUTTLE',
                  style: AppTextStyles.button.copyWith(color: AppColors.error),
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
          builder: (_) => SnoozeChoreDialog(currentDueDate: chore.dueDate!),
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
        if (value == true) {
          if (currentUser == null) return;
          final result = await showDialog<Map<String, String?>>(
            context: context,
            builder: (_) => ChoreCompletionDialog(choreId: chore.id),
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
        } else {
          await ref
              .read(choreControllerProvider.notifier)
              .uncompleteChore(chore.id);
        }
      },
    );
  }
}
