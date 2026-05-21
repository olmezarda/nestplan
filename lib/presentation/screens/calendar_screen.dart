import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/plan_model.dart';
import '../../data/sources/database_helper.dart';
import '../widgets/calendar_accordion_tile.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<PlanModel>> _groupedPlans = {};
  late List<PlanModel> _selectedPlans;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedPlans = [];
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final plans = await DatabaseHelper.instance.getMainPlans();
    final Map<DateTime, List<PlanModel>> grouped = {};

    for (var plan in plans) {
      if (plan.isRange == 1 && plan.endDate != null) {
        final startDate = DateFormat('dd/MM/yyyy').parse(plan.date);
        final endDate = DateFormat('dd/MM/yyyy').parse(plan.endDate!);

        for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
          final currentDay = startDate.add(Duration(days: i));
          final normalizedDate = DateTime.utc(
            currentDay.year,
            currentDay.month,
            currentDay.day,
          );
          if (grouped[normalizedDate] == null) grouped[normalizedDate] = [];
          grouped[normalizedDate]!.add(plan);
        }
      } else {
        final parsedDate = DateFormat('dd/MM/yyyy').parse(plan.date);
        final normalizedDate = DateTime.utc(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );
        if (grouped[normalizedDate] == null) grouped[normalizedDate] = [];
        grouped[normalizedDate]!.add(plan);
      }
    }

    if (mounted) {
      setState(() {
        _groupedPlans = grouped;
        if (_selectedDay != null) {
          _selectedPlans = _getPlansForDay(_selectedDay!);
        }
      });
    }
  }

  List<PlanModel> _getPlansForDay(DateTime day) {
    final normalizedDate = DateTime.utc(day.year, day.month, day.day);
    return _groupedPlans[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surface : AppColors.surfaceLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.glassBorder : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Takvim Görünümü', style: TextStyle(color: textM)),
        scrolledUnderElevation: 0.0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(AppSizes.pMedium),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppSizes.rLarge),
              border: Border.all(color: borderColor),
            ),
            child: TableCalendar<PlanModel>(
              locale: 'tr_TR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getPlansForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: AppColors.aiHighlight,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.accentGold,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: textM),
                weekendTextStyle: const TextStyle(color: AppColors.error),
                outsideTextStyle: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: textM,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(LucideIcons.chevronLeft, color: textM),
                rightChevronIcon: Icon(LucideIcons.chevronRight, color: textM),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppColors.textSecondary),
                weekendStyle: TextStyle(color: AppColors.error),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedPlans = _getPlansForDay(selectedDay);
                  });
                }
              },
            ),
          ),
          const SizedBox(height: AppSizes.pMedium),
          Expanded(
            child: _selectedPlans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.calendarX,
                          size: 48,
                          color: textS.withValues(alpha: 0.5),
                        ),
                        AppSizes.hBoxNormal,
                        Text(
                          'Bu güne ait plan yok.',
                          style: TextStyle(color: textS),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pMedium,
                    ),
                    itemCount: _selectedPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _selectedPlans[index];
                      return CalendarAccordionTile(
                        key: ValueKey(
                          'main_${plan.id}_${_selectedDay!.millisecondsSinceEpoch}',
                        ),
                        plan: plan,
                        selectedDate: _selectedDay!,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
