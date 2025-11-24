import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../core/models/chore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ChoreListItem extends StatelessWidget {
  final Chore chore;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;

  const ChoreListItem({
    super.key,
    required this.chore,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, y').format(chore.nextDueAt);
    final isOverdue = chore.nextDueAt.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(chore.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: AppColors.editGray,
                foregroundColor: AppColors.textPrimary,
                icon: Icons.edit,
                label: 'Edit',
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: AppColors.errorAlt,
                foregroundColor: AppColors.textPrimary,
                icon: Icons.delete,
                label: 'Delete',
              ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardDarkAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Circle indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? AppColors.error.withValues(alpha: 0.2)
                        : AppColors.primaryPurple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cleaning_services,
                    color: isOverdue
                        ? AppColors.error
                        : AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Chore details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chore.title, style: AppTextStyles.body),
                      const SizedBox(height: 4),
                      Text(
                        chore.assignedTo != null
                            ? 'Assigned to: ${chore.assignedTo}'
                            : 'Unassigned',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${chore.schedule.frequency} x ${chore.schedule.interval}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),

                // Complete button
                if (onComplete != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: onComplete,
                    color: AppColors.primaryPurple,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
