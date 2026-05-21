import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/plan_model.dart';
import '../../data/sources/database_helper.dart';
import '../screens/plan_detail_screen.dart';

class DayPlansSheet extends StatelessWidget {
  final DateTime day;
  final List<PlanModel> plans;
  final VoidCallback onRefresh;
  final Function(DateTime) onAddPlan;
  final Function(PlanModel, DateTime) onEditPlan;

  const DayPlansSheet({
    super.key,
    required this.day,
    required this.plans,
    required this.onRefresh,
    required this.onAddPlan,
    required this.onEditPlan,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.pLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${DateFormat('dd/MM/yyyy', 'tr_TR').format(day)} Planları',
            style: TextStyle(
              color: textM,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSizes.hBoxNormal,
          plans.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(AppSizes.pLarge),
                  child: Text(
                    'Henüz plan yok.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        LucideIcons.target,
                        color: AppColors.primary,
                      ),
                      title: Text(plan.title, style: TextStyle(color: textM)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              LucideIcons.edit3,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onEditPlan(plan, day);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              LucideIcons.trash2,
                              size: 18,
                              color: AppColors.error,
                            ),
                            onPressed: () async {
                              await DatabaseHelper.instance.deletePlan(
                                plan.id!,
                              );
                              onRefresh();
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlanDetailScreen(plan: plan),
                          ),
                        ).then((_) => onRefresh());
                      },
                    );
                  },
                ),
          AppSizes.hBoxNormal,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onAddPlan(day);
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Yeni Plan Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
