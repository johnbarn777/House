import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/house_note.dart';
import '../providers/house_notes_provider.dart';

class NoteListItem extends ConsumerWidget {
  final HouseNote note;
  final String currentUserId;
  final VoidCallback onEdit;

  const NoteListItem({
    super.key,
    required this.note,
    required this.currentUserId,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine color based on urgency
    Color urgencyColor;
    IconData urgencyIcon;

    switch (note.urgency) {
      case NoteUrgency.urgent:
        urgencyColor = AppColors.error;
        urgencyIcon = Icons.error_outline;
        break;
      case NoteUrgency.important:
        urgencyColor = AppColors.warning;
        urgencyIcon = Icons.warning_amber_rounded;
        break;
      case NoteUrgency.info:
        urgencyColor = AppColors.textParchment;
        urgencyIcon = Icons.info_outline;
        break;
    }

    final isCreator = note.creatorId == currentUserId;

    return Dismissible(
      key: Key(note.id),
      direction: isCreator
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.accentRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundParchment,
            title: Text('Delete Note?', style: AppTextStyles.cardTitle),
            content: Text(
              'Are you sure you want to delete this note?',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: AppTextStyles.button),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: AppTextStyles.button.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(houseNotesControllerProvider.notifier).deleteNote(note.id);
      },
      child: GestureDetector(
        onTap: isCreator ? onEdit : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWood,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: note.isPinned ? AppColors.primarySea : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(urgencyIcon, color: urgencyColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title,
                      style: AppTextStyles.bodyLight.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (note.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.push_pin,
                        color: AppColors.primarySea,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(note.content, style: AppTextStyles.bodyLight),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, h:mm a').format(note.createdAt),
                    style: AppTextStyles.caption,
                  ),
                  if (isCreator)
                    Icon(Icons.edit, size: 14, color: AppColors.textParchment),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
