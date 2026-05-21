import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/template_model.dart';

class TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onApply;
  final Function(TemplateModel) onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onEdit,
    required this.onApply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Dismissible(
      key: Key(template.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: AppSizes.pMedium),
        padding: const EdgeInsets.only(right: AppSizes.pLarge),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.rMedium),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      confirmDismiss: (direction) async => await UIHelpers.showConfirmDialog(
        context,
        'Şablonu Sil',
        'Bu şablonu silmek istediğine emin misin?',
      ),
      onDismissed: (direction) => onDelete(template),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.pMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rMedium),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pMedium,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.aiHighlight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.rSmall),
            ),
            child: const Icon(LucideIcons.copy, color: AppColors.aiHighlight),
          ),
          title: Text(
            template.title,
            style: TextStyle(color: textM, fontWeight: FontWeight.bold),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.calendarPlus,
                  color: AppColors.success,
                ),
                onPressed: onApply,
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.edit3,
                  color: AppColors.textSecondary,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: AppColors.error),
                onPressed: () async {
                  final confirm = await UIHelpers.showConfirmDialog(
                    context,
                    'Şablonu Sil',
                    'Bu şablonu silmek istediğine emin misin?',
                  );
                  if (confirm) onDelete(template);
                },
              ),
              const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
