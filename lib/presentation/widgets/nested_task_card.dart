import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/nested_task_model.dart';

class NestedTaskCard extends StatelessWidget {
  final NestedTaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDeleteIconTap;
  final VoidCallback onDismissed;

  const NestedTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDeleteIconTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;

    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await UIHelpers.showConfirmDialog(
          context,
          'Görevi Sil',
          '"${task.title}" görevini silmek istediğine emin misin?',
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.pLarge),
        color: AppColors.error,
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (direction) => onDismissed(),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.pSmall),
        child: ListTile(
          onTap: onToggle,
          leading: Icon(
            task.isCompleted == 1
                ? LucideIcons.checkCircle2
                : LucideIcons.circle,
            color: task.isCompleted == 1 ? AppColors.success : textS,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isCompleted == 1 ? textS : textM,
              decoration: task.isCompleted == 1
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: task.detail != null && task.detail!.isNotEmpty
              ? Text(
                  task.detail!,
                  style: TextStyle(
                    color: task.isCompleted == 1
                        ? textS.withValues(alpha: 0.5)
                        : textS,
                    decoration: task.isCompleted == 1
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.time != null) ...[
                const Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: AppColors.aiHighlight,
                ),
                const SizedBox(width: 4),
                Text(
                  task.time!,
                  style: const TextStyle(
                    color: AppColors.aiHighlight,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: const Icon(
                  LucideIcons.edit3,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: onDeleteIconTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
