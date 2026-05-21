import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/template_model.dart';
import '../../data/models/template_task_model.dart';
import '../../data/sources/database_helper.dart';
import '../widgets/add_template_task_sheet.dart';
import '../widgets/template_task_card.dart';

class TemplateDetailScreen extends StatefulWidget {
  final TemplateModel template;
  const TemplateDetailScreen({super.key, required this.template});

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  List<TemplateTaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper.instance.getTemplateTasks(
      widget.template.id!,
    );
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  void _showAddTaskSheet({TemplateTaskModel? task}) {
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
      builder: (_) => AddTemplateTaskSheet(
        templateId: widget.template.id!,
        onTaskAdded: _loadTasks,
        existingTask: task,
      ),
    );
  }

  Future<void> _deleteTask(TemplateTaskModel task) async {
    await DatabaseHelper.instance.deleteTemplateTask(task.id!);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColors.bgLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.template.title, style: TextStyle(color: textM)),
        backgroundColor: bg,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _tasks.isEmpty
          ? Center(
              child: Text(
                'Bu şablonda henüz görev yok.',
                style: TextStyle(color: textS),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.pMedium),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return TemplateTaskCard(
                  task: task,
                  onEdit: () => _showAddTaskSheet(task: task),
                  onDelete: _deleteTask,
                );
              },
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
