import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../models/chore.dart';

class ChoreListItem extends ConsumerWidget {
  final Chore chore;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCompletionChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSnooze;

  const ChoreListItem({
    super.key,
    required this.chore,
    this.onTap,
    this.onCompletionChanged,
    this.onEdit,
    this.onDelete,
    this.onSnooze,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        chore.dueDate != null &&
        app_date_utils.DateUtils.isOverdue(chore.dueDate!) &&
        !chore.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Slidable(
        key: ValueKey(chore.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onSnooze != null &&
                !chore.isCompleted) // Only snoozable if not completed
              SlidableAction(
                onPressed: (_) => onSnooze!(),
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                icon: Icons.access_time, // Snooze icon
                label: 'Snooze',
                // No border radius on left side of this pane usually, or shared if multiple
              ),
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
              ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: isOverdue
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Checkbox
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: chore.isCompleted,
                    onChanged: onCompletionChanged,
                    activeColor: AppColors.primaryPurple,
                    checkColor: Colors.white,
                    side: const BorderSide(color: AppColors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chore.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: chore.isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          decoration: chore.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (chore.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: isOverdue
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              app_date_utils.DateUtils.formatTaskDate(
                                chore.dueDate!,
                              ),
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                                fontWeight: isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (chore.repeatSchedule !=
                                RepeatSchedule.none) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.repeat,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                      if (chore.isCompleted &&
                          chore.completionNote != null &&
                          chore.completionNote!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '"${chore.completionNote}"',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Assignee Avatar (Placeholder for now)
                if (chore.assignedToIds.isNotEmpty)
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.inputBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),

                // Completion Photo (if present)
                if (chore.isCompleted &&
                    chore.photoUrl != null &&
                    chore.photoUrl!.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: InteractiveViewer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(chore.photoUrl!),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          chore.photoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
