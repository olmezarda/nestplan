import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/nested_task_model.dart';
import '../../data/models/template_model.dart';
import '../../data/sources/database_helper.dart';
import '../widgets/template_card.dart';
import 'template_detail_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<TemplateModel> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = await DatabaseHelper.instance.getTemplates();
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  void _showAddTemplateSheet({TemplateModel? existingTemplate}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(
      text: existingTemplate?.title ?? '',
    );

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existingTemplate != null
                  ? 'Şablonu Düzenle'
                  : 'Yeni Şablon Oluştur',
              style: TextStyle(
                color: isDark ? AppColors.textMain : AppColors.textMainLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSizes.hBoxHigh,
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Şablon Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rMedium),
                ),
              ),
            ),
            AppSizes.hBoxHigh,
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final newTemplate = TemplateModel(
                  id: existingTemplate?.id,
                  title: titleController.text.trim(),
                );
                existingTemplate != null
                    ? await DatabaseHelper.instance.updateTemplate(newTemplate)
                    : await DatabaseHelper.instance.insertTemplate(newTemplate);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadTemplates();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            AppSizes.hBoxHigh,
          ],
        ),
      ),
    );
  }

  Future<void> _applyTemplateToMultipleDates(TemplateModel template) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Set<DateTime> selectedDays = {};
    DateTime focusedDay = DateTime.now();

    final bool? shouldApply = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
          title: const Text('Günleri Seçin'),
          content: SizedBox(
            width: double.maxFinite,
            child: TableCalendar(
              locale: 'tr_TR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) =>
                  selectedDays.any((d) => isSameDay(d, day)),
              onDaySelected: (selectedDay, fDay) => setDialogState(() {
                focusedDay = fDay;
                selectedDays.any((d) => isSameDay(d, selectedDay))
                    ? selectedDays.removeWhere((d) => isSameDay(d, selectedDay))
                    : selectedDays.add(selectedDay);
              }),
              headerStyle: const HeaderStyle(formatButtonVisible: false),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Uygula'),
            ),
          ],
        ),
      ),
    );

    if (shouldApply != true || selectedDays.isEmpty || !mounted) return;

    final tasks = await DatabaseHelper.instance.getTemplateTasks(template.id!);

    for (var day in selectedDays) {
      final dateStr = DateFormat('dd/MM/yyyy').format(day);
      final planId = await DatabaseHelper.instance.insertPlan(
        PlanModel(title: template.title, date: dateStr, isRange: 0),
      );
      for (var task in tasks) {
        await DatabaseHelper.instance.insertNestedTask(
          NestedTaskModel(
            planId: planId,
            title: task.title,
            detail: task.detail,
            time: task.time,
            isCompleted: 0,
          ),
        );
      }
    }
    if (mounted) {
      UIHelpers.showCustomSnackBar(
        context,
        '${template.title} başarıyla eklendi!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Şablonlarım'),
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? AppColors.background : AppColors.bgLight,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _templates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.copy,
                    size: 64,
                    color: textS.withValues(alpha: 0.5),
                  ),
                  AppSizes.hBoxNormal,
                  Text(
                    'Henüz bir şablon yok.',
                    style: TextStyle(
                      color: textS,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.pMedium),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return TemplateCard(
                  template: template,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TemplateDetailScreen(template: template),
                    ),
                  ),
                  onEdit: () =>
                      _showAddTemplateSheet(existingTemplate: template),
                  onApply: () => _applyTemplateToMultipleDates(template),
                  onDelete: (t) async {
                    await DatabaseHelper.instance.deleteTemplate(t.id!);
                    _loadTemplates();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateSheet(),
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
