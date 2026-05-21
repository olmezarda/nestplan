import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/plan_model.dart';
import '../../data/sources/database_helper.dart';

class PlanCard extends StatefulWidget {
  final PlanModel plan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  int _subItemCount = -1;

  @override
  void initState() {
    super.initState();
    _loadSubItemsCount();
  }

  @override
  void didUpdateWidget(covariant PlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadSubItemsCount();
  }

  Future<void> _loadSubItemsCount() async {
    int count = 0;
    if (widget.plan.isRange == 1) {
      final db = await DatabaseHelper.instance.database;
      final res = await db.rawQuery(
        'SELECT COUNT(*) as count FROM plans WHERE parentId = ?',
        [widget.plan.id],
      );
      count = (res.first['count'] as int?) ?? 0;
    } else {
      final tasks = await DatabaseHelper.instance.getNestedTasks(
        widget.plan.id!,
      );
      count = tasks.length;
    }
    if (mounted) setState(() => _subItemCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRange = widget.plan.isRange == 1;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Dismissible(
      key: Key(widget.plan.id.toString()),
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
        'Planı Sil',
        '"${widget.plan.title}" planını ve içindeki tüm görevleri silmek istediğine emin misin?',
      ),
      onDismissed: (direction) => widget.onDelete(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.pMedium),
          padding: const EdgeInsets.all(AppSizes.pMedium),
          decoration: BoxDecoration(
            color: isRange
                ? AppColors.aiHighlight.withValues(alpha: isDark ? 0.05 : 0.15)
                : (isDark ? AppColors.surface : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(AppSizes.rMedium),
            border: Border.all(
              color: isRange
                  ? AppColors.aiHighlight.withValues(alpha: 0.3)
                  : (isDark ? AppColors.glassBorder : Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRange
                      ? AppColors.aiHighlight.withValues(alpha: 0.2)
                      : (isDark
                            ? AppColors.glassSurface
                            : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(AppSizes.rSmall),
                ),
                child: Icon(
                  isRange ? LucideIcons.calendarRange : LucideIcons.target,
                  color: isRange ? AppColors.aiHighlight : AppColors.primary,
                ),
              ),
              AppSizes.wBoxNormal,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.title,
                      style: TextStyle(
                        color: textM,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSizes.hBoxLow,
                    Text(
                      isRange
                          ? '${widget.plan.date} - ${widget.plan.endDate}'
                          : widget.plan.date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (_subItemCount == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.info,
                              color: AppColors.accentGold,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'Alt plan oluşturulmadı!',
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.edit3,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: widget.onEdit,
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () async {
                      final confirm = await UIHelpers.showConfirmDialog(
                        context,
                        'Planı Sil',
                        '"${widget.plan.title}" planını ve içindeki tüm görevleri silmek istediğine emin misin?',
                      );
                      if (confirm && mounted) {
                        widget.onDelete();
                      }
                    },
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
