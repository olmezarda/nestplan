import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/nested_task_model.dart';
import '../../data/sources/database_helper.dart';
import '../widgets/add_nested_task_sheet.dart';
import '../widgets/nested_task_card.dart';

class PlanDetailScreen extends StatefulWidget {
  final PlanModel plan;

  const PlanDetailScreen({super.key, required this.plan});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  late Future<List<NestedTaskModel>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = DatabaseHelper.instance.getNestedTasks(widget.plan.id!);
    });
  }

  void _showAddTaskSheet({NestedTaskModel? task}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      builder: (_) => AddNestedTaskSheet(
        planId: widget.plan.id!,
        onTaskAdded: _refreshTasks,
        existingTask: task,
      ),
    );
  }

  void _requestDeleteTask(NestedTaskModel task) async {
    final confirm = await UIHelpers.showConfirmDialog(
      context,
      'Görevi Sil',
      '"${task.title}" görevini silmek istediğine emin misin?',
    );

    if (confirm && mounted) {
      await DatabaseHelper.instance.deleteNestedTask(task.id!);
      _refreshTasks();
      if (mounted) {
        UIHelpers.showCustomSnackBar(
          context,
          '"${task.title}" silindi.',
          isError: true,
        );
      }
    }
  }

  void _deleteTaskDirectly(NestedTaskModel task) async {
    await DatabaseHelper.instance.deleteNestedTask(task.id!);
    _refreshTasks();
    if (mounted) {
      UIHelpers.showCustomSnackBar(
        context,
        '"${task.title}" silindi.',
        isError: true,
      );
    }
  }

  void _toggleTaskCompletion(NestedTaskModel task) async {
    await DatabaseHelper.instance.toggleTaskCompletion(
      task.id!,
      task.isCompleted,
    );
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColors.bgLight;
    final surface = isDark ? AppColors.surface : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.glassBorder : Colors.grey.shade300;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.plan.title, style: TextStyle(color: textM)),
        backgroundColor: bg,
        scrolledUnderElevation: 0.0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.pLarge),
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarih: ${widget.plan.date}',
                  style: TextStyle(color: textS, fontSize: 16),
                ),
                if (widget.plan.time != null)
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: AppColors.aiHighlight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.plan.time!,
                        style: const TextStyle(
                          color: AppColors.aiHighlight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NestedTaskModel>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Hata: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.listTodo,
                          size: 64,
                          color: textS.withValues(alpha: 0.5),
                        ),
                        AppSizes.hBoxNormal,
                        Text(
                          'Alt görev bulunamadı.',
                          style: TextStyle(
                            color: textS,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final tasks = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.pMedium),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return NestedTaskCard(
                      task: task,
                      onToggle: () => _toggleTaskCompletion(task),
                      onEdit: () => _showAddTaskSheet(task: task),
                      onDeleteIconTap: () => _requestDeleteTask(task),
                      onDismissed: () => _deleteTaskDirectly(task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
