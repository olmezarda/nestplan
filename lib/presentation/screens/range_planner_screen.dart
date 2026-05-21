import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/plan_model.dart';
import '../../data/sources/database_helper.dart';
import '../widgets/add_plan_sheet.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/day_plans_sheet.dart';

class RangePlannerScreen extends StatefulWidget {
  final PlanModel rangePlan;

  const RangePlannerScreen({super.key, required this.rangePlan});

  @override
  State<RangePlannerScreen> createState() => _RangePlannerScreenState();
}

class _RangePlannerScreenState extends State<RangePlannerScreen> {
  late List<DateTime> _daysInRange;
  final Map<String, List<PlanModel>> _dailyPlans = {};
  final List<String> _trDays = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  @override
  void initState() {
    super.initState();
    final start = DateFormat('dd/MM/yyyy').parse(widget.rangePlan.date);
    final end = DateFormat('dd/MM/yyyy').parse(widget.rangePlan.endDate!);
    _daysInRange = _getDaysInRange(start, end);
    _loadDailyPlans();
  }

  Future<void> _loadDailyPlans() async {
    _dailyPlans.clear();
    for (var day in _daysInRange) {
      final dateStr = DateFormat('dd/MM/yyyy').format(day);
      final plans = await DatabaseHelper.instance.getPlansByDateAndParent(
        dateStr,
        widget.rangePlan.id!,
      );
      if (plans.isNotEmpty) _dailyPlans[dateStr] = plans;
    }
    if (mounted) setState(() {});
  }

  List<DateTime> _getDaysInRange(DateTime start, DateTime end) {
    return List.generate(
      end.difference(start).inDays + 1,
      (i) => start.add(Duration(days: i)),
    );
  }

  void _showDayPlansSheet(DateTime day, List<PlanModel> plans) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      builder: (_) => DayPlansSheet(
        day: day,
        plans: plans,
        onRefresh: _loadDailyPlans,
        onAddPlan: _showAddPlanForm,
        onEditPlan: (plan, day) => _showAddPlanForm(day, existingPlan: plan),
      ),
    );
  }

  void _showAddPlanForm(DateTime day, {PlanModel? existingPlan}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      builder: (_) => AddPlanSheet(
        initialDate: day,
        existingPlan: existingPlan,
        onPlanAdded: _loadDailyPlans,
        parentId: widget.rangePlan.id,
      ),
    );
  }

  void _editRangePlan() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final titleController = TextEditingController(text: widget.rangePlan.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: AppSizes.pLarge,
          right: AppSizes.pLarge,
          top: AppSizes.pLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aralık Planını Düzenle',
              style: TextStyle(
                color: textM,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSizes.hBoxHigh,
            TextField(
              controller: titleController,
              style: TextStyle(color: textM),
            ),
            AppSizes.hBoxHigh,
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final updated = PlanModel(
                  id: widget.rangePlan.id,
                  title: titleController.text.trim(),
                  date: widget.rangePlan.date,
                  endDate: widget.rangePlan.endDate,
                  isRange: 1,
                  parentId: widget.rangePlan.parentId,
                );
                await DatabaseHelper.instance.updatePlan(updated);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RangePlannerScreen(rangePlan: updated),
                    ),
                  );
                }
              },
              child: const Text('Güncelle'),
            ),
            AppSizes.hBoxHigh,
          ],
        ),
      ),
    );
  }

  void _deleteRangePlan() async {
    final confirm = await UIHelpers.showConfirmDialog(
      context,
      'Aralık Planını Sil',
      'Bu kampı silmek istediğine emin misin?',
    );
    if (confirm) {
      await DatabaseHelper.instance.deletePlan(widget.rangePlan.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColors.bgLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: bg,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.rangePlan.title,
              style: TextStyle(
                color: textM,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.rangePlan.date} - ${widget.rangePlan.endDate}',
              style: const TextStyle(
                color: AppColors.aiHighlight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit3, color: AppColors.textSecondary),
            onPressed: _editRangePlan,
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppColors.error),
            onPressed: _deleteRangePlan,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSizes.pMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSizes.pMedium,
          mainAxisSpacing: AppSizes.pMedium,
          childAspectRatio: 0.85,
        ),
        itemCount: _daysInRange.length,
        itemBuilder: (context, index) {
          final day = _daysInRange[index];
          final dateStr = DateFormat('dd/MM/yyyy').format(day);
          final plansForDay = _dailyPlans[dateStr] ?? [];
          final isToday =
              dateStr == DateFormat('dd/MM/yyyy').format(DateTime.now());

          return CalendarDayCell(
            day: day,
            plans: plansForDay,
            isToday: isToday,
            dayName: _trDays[day.weekday - 1],
            onTap: () => _showDayPlansSheet(day, plansForDay),
          );
        },
      ),
    );
  }
}
