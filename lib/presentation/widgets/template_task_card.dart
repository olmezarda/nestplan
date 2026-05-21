import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/template_task_model.dart';

class TemplateTaskCard extends StatelessWidget {
  final TemplateTaskModel task;
  final VoidCallback onEdit;
  final Function(TemplateTaskModel) onDelete;

  const TemplateTaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
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
      confirmDismiss: (direction) async => await UIHelpers.showConfirmDialog(
        context,
        'İçeriği Sil',
        'Bu içeriği silmek istediğine emin misin?',
      ),
      onDismissed: (direction) => onDelete(task),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.pLarge),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.rMedium),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.pSmall),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(color: textM, fontWeight: FontWeight.bold),
          ),
          subtitle: task.detail != null
              ? Text(task.detail!, style: TextStyle(color: textS))
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.time != null)
                Text(
                  task.time!,
                  style: const TextStyle(
                    color: AppColors.aiHighlight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              IconButton(
                icon: const Icon(LucideIcons.edit3, size: 18),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  color: AppColors.error,
                  size: 18,
                ),
                onPressed: () => onDelete(task),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
