import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/nested_task_model.dart';
import '../../data/sources/database_helper.dart';

class CalendarAccordionTile extends StatefulWidget {
  final PlanModel plan;
  final DateTime selectedDate;
  final bool isNested;

  const CalendarAccordionTile({
    super.key,
    required this.plan,
    required this.selectedDate,
    this.isNested = false,
  });

  @override
  State<CalendarAccordionTile> createState() => _CalendarAccordionTileState();
}

class _CalendarAccordionTileState extends State<CalendarAccordionTile> {
  List<PlanModel> _childPlans = [];
  List<NestedTaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant CalendarAccordionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan.id != widget.plan.id ||
        oldWidget.selectedDate != widget.selectedDate) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    if (widget.plan.isRange == 1) {
      final dateStr = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
      _childPlans = await DatabaseHelper.instance.getPlansByDateAndParent(
        dateStr,
        widget.plan.id!,
      );
    } else {
      _tasks = await DatabaseHelper.instance.getNestedTasks(widget.plan.id!);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surface : AppColors.surfaceLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.glassBorder : Colors.grey.shade300;
    final iconBg = isDark ? AppColors.glassSurface : Colors.grey.shade200;
    final isRange = widget.plan.isRange == 1;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: widget.isNested
            ? EdgeInsets.zero
            : const EdgeInsets.only(bottom: AppSizes.pMedium),
        decoration: widget.isNested
            ? null
            : BoxDecoration(
                color: isRange
                    ? AppColors.aiHighlight.withValues(
                        alpha: isDark ? 0.05 : 0.15,
                      )
                    : cardBg,
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
                border: Border.all(
                  color: isRange
                      ? AppColors.aiHighlight.withValues(alpha: 0.3)
                      : borderColor,
                ),
              ),
        child: ExpansionTile(
          tilePadding: widget.isNested
              ? const EdgeInsets.symmetric(
                  horizontal: AppSizes.pLarge,
                  vertical: 0,
                )
              : const EdgeInsets.symmetric(
                  horizontal: AppSizes.pMedium,
                  vertical: 8,
                ),
          leading: widget.isNested
              ? const Icon(
                  LucideIcons.calendarDays,
                  color: AppColors.primary,
                  size: 20,
                )
              : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRange
                        ? AppColors.aiHighlight.withValues(alpha: 0.2)
                        : iconBg,
                    borderRadius: BorderRadius.circular(AppSizes.rSmall),
                  ),
                  child: Icon(
                    isRange ? LucideIcons.calendarRange : LucideIcons.target,
                    color: isRange ? AppColors.aiHighlight : AppColors.primary,
                  ),
                ),
          title: Text(
            widget.plan.title,
            style: TextStyle(
              color: textM,
              fontSize: widget.isNested ? 15 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: widget.isNested
              ? null
              : Text(
                  isRange
                      ? '${widget.plan.date} - ${widget.plan.endDate}'
                      : widget.plan.date,
                  style: TextStyle(color: textS, fontSize: 12),
                ),
          iconColor: AppColors.primary,
          collapsedIconColor: textS,
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (isRange && _childPlans.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bu güne ait plan bulunamadı.',
                  style: TextStyle(color: textS),
                ),
              )
            else if (!isRange && _tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bu plana ait görev bulunamadı.',
                  style: TextStyle(color: textS),
                ),
              )
            else if (isRange)
              ..._childPlans.map(
                (childPlan) => CalendarAccordionTile(
                  key: ValueKey(
                    'child_${childPlan.id}_${widget.selectedDate.millisecondsSinceEpoch}',
                  ),
                  plan: childPlan,
                  selectedDate: widget.selectedDate,
                  isNested: true,
                ),
              )
            else
              Column(
                children: _tasks.map((task) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.isNested
                          ? AppSizes.pLarge * 1.5
                          : AppSizes.pLarge,
                    ),
                    onTap: () async {
                      await DatabaseHelper.instance.toggleTaskCompletion(
                        task.id!,
                        task.isCompleted,
                      );
                      _loadData();
                    },
                    leading: Icon(
                      task.isCompleted == 1
                          ? LucideIcons.checkCircle2
                          : LucideIcons.circle,
                      color: task.isCompleted == 1 ? AppColors.success : textS,
                      size: 20,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted == 1 ? textS : textM,
                        decoration: task.isCompleted == 1
                            ? TextDecoration.lineThrough
                            : null,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: task.detail != null && task.detail!.isNotEmpty
                        ? Text(
                            task.detail!,
                            style: TextStyle(
                              color: task.isCompleted == 1
                                  ? textS.withValues(alpha: 0.6)
                                  : textS,
                              decoration: task.isCompleted == 1
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          )
                        : null,
                    trailing: task.time != null
                        ? Text(
                            task.time!,
                            style: const TextStyle(
                              color: AppColors.aiHighlight,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
