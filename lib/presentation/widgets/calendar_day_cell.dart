import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/plan_model.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final List<PlanModel> plans;
  final bool isToday;
  final VoidCallback onTap;
  final String dayName;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.plans,
    required this.isToday,
    required this.onTap,
    required this.dayName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPlan = plans.isNotEmpty;

    Color cardBg = isDark ? AppColors.surface : AppColors.surfaceLight;
    Color borderColor = isDark ? AppColors.glassBorder : Colors.grey.shade300;
    Color dayTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    Color dateTextColor = isDark ? AppColors.textMain : AppColors.textMainLight;

    if (hasPlan) {
      cardBg = AppColors.aiHighlight.withValues(alpha: isDark ? 0.15 : 0.1);
      borderColor = AppColors.aiHighlight.withValues(alpha: 0.5);
      dayTextColor = isDark ? AppColors.aiHighlight : AppColors.primaryDark;
      dateTextColor = isDark ? Colors.white : AppColors.textMainLight;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.rMedium),
          border: Border.all(
            color: isToday && !hasPlan ? AppColors.primary : borderColor,
            width: isToday || hasPlan ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isToday && !hasPlan ? AppColors.primary : dayTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd').format(day),
              style: TextStyle(
                color: dateTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (hasPlan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.aiHighlight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plans.length > 1
                      ? '${plans.length} Görev'
                      : plans.first.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Icon(
                LucideIcons.plusCircle,
                color: AppColors.aiHighlight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
