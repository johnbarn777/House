import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/parchment_card.dart';
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
                foregroundColor: AppColors.textLight,
                icon: Icons.delete,
                label: 'Scuttle',
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onSnooze != null && !chore.isCompleted)
              SlidableAction(
                onPressed: (_) => onSnooze!(),
                backgroundColor: AppColors.warning,
                foregroundColor: AppColors.textInk,
                icon: Icons.access_time,
                label: 'Delay',
              ),
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textLight,
                icon: Icons.edit,
                label: 'Amend',
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: ParchmentCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: () => onCompletionChanged?.call(!chore.isCompleted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: chore.isCompleted
                          ? AppColors.primarySea
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: chore.isCompleted
                            ? AppColors.primarySea
                            : AppColors.textInk,
                        width: 2,
                      ),
                    ),
                    child: chore.isCompleted
                        ? const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.secondaryGold,
                          ) // X mark like a treasure map
                        : null,
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
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: chore.isCompleted
                              ? AppColors.textParchment
                              : AppColors.textInk,
                          decoration: chore.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.error, // Red slash
                          decorationThickness: 2,
                        ),
                      ),
                      if (chore.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: isOverdue
                                  ? AppColors.error
                                  : AppColors.textParchment,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              app_date_utils.DateUtils.formatTaskDate(
                                chore.dueDate!,
                              ).toUpperCase(),
                              style: AppTextStyles.caption.copyWith(
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textParchment,
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
                                size: 12,
                                color: AppColors.textParchment,
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
                          'LOG: "${chore.completionNote}"',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textParchment,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Assignee & Photo
                if (chore.assignedToIds.isNotEmpty)
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(left: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundParchment,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textInk.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textInk,
                    ),
                  ),

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
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primarySea),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            chore.photoUrl!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
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
