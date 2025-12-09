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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool?>? onCompletionChanged;

  const ChoreListItem({
    super.key,
    required this.chore,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCompletionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        chore.dueDate != null &&
        app_date_utils.DateUtils.isOverdue(chore.dueDate!) &&
        !chore.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: ValueKey(chore.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppColors.editGray,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (_) {
                // Confirm delete logic could be here, but for now just call callback
                onDelete?.call();
              },
              backgroundColor: AppColors.deleteRed,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
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
