import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/house_notes_provider.dart';

import 'note_list_item.dart';
import 'add_edit_note_dialog.dart';
import '../../../core/providers/auth_provider.dart';

class HouseNotesModule extends ConsumerWidget {
  const HouseNotesModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(houseNotesProvider);
    final user = ref.watch(authStateProvider).value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWood,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('House Notes', style: AppTextStyles.moduleTitle),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddEditNoteDialog(),
                  );
                },
                icon: const Icon(Icons.add, color: AppColors.accentRed),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return Text('No notes yet.', style: AppTextStyles.bodyLight);
              }

              final pinnedNotes = notes.where((n) => n.isPinned).toList();
              final otherNotes = notes.where((n) => !n.isPinned).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pinnedNotes.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.push_pin,
                          size: 14,
                          color: AppColors.textParchment,
                        ),
                        const SizedBox(width: 4),
                        Text('Pinned', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...pinnedNotes.map(
                      (note) => NoteListItem(
                        note: note,
                        currentUserId: user?.uid ?? '',
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddEditNoteDialog(note: note),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (otherNotes.isNotEmpty) ...[
                    if (pinnedNotes.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.notes,
                            size: 14,
                            color: AppColors.textParchment,
                          ),
                          const SizedBox(width: 4),
                          Text('General', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    ...otherNotes.map(
                      (note) => NoteListItem(
                        note: note,
                        currentUserId: user?.uid ?? '',
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddEditNoteDialog(note: note),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (err, stack) =>
                Text('Failed to load notes', style: AppTextStyles.error),
          ),
        ],
      ),
    );
  }
}
