import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/plan_model.dart';
import '../../data/sources/database_helper.dart';
import '../../core/utils/ui_helpers.dart';

class AddPlanSheet extends StatefulWidget {
  final VoidCallback onPlanAdded;
  final DateTime? initialDate;
  final int? parentId;
  final PlanModel? existingPlan;

  const AddPlanSheet({
    super.key,
    required this.onPlanAdded,
    this.initialDate,
    this.parentId,
    this.existingPlan,
  });

  @override
  State<AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<AddPlanSheet> {
  final _titleController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null) {
      _titleController.text = widget.existingPlan!.title;
      _selectedDate = DateFormat('dd/MM/yyyy').parse(widget.existingPlan!.date);
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: AppColors.background,
                    surface: AppColors.surface,
                    onSurface: AppColors.textMain,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.surfaceLight,
                    onSurface: AppColors.textMainLight,
                  ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      if (mounted) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  void _savePlan() async {
    if (_titleController.text.trim().isEmpty) {
      UIHelpers.showCustomSnackBar(
        context,
        'Lütfen bir plan başlığı girin.',
        isError: true,
      );
      return;
    }

    final newPlan = PlanModel(
      id: widget.existingPlan?.id,
      title: _titleController.text.trim(),
      date: DateFormat('dd/MM/yyyy').format(_selectedDate),
      time: null,
      endDate: widget.existingPlan?.endDate,
      isRange: widget.existingPlan?.isRange ?? 0,
      parentId: widget.existingPlan?.parentId ?? widget.parentId,
    );

    if (widget.existingPlan != null) {
      await DatabaseHelper.instance.updatePlan(newPlan);
      if (mounted) {
        UIHelpers.showCustomSnackBar(context, 'Plan başarıyla güncellendi.');
      }
    } else {
      await DatabaseHelper.instance.insertPlan(newPlan);
      if (mounted) {
        UIHelpers.showCustomSnackBar(context, 'Yeni plan başarıyla eklendi.');
      }
    }

    widget.onPlanAdded();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surface : AppColors.surfaceLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final borderColor = isDark ? AppColors.glassBorder : Colors.grey.shade300;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSizes.pLarge,
        right: AppSizes.pLarge,
        top: AppSizes.pLarge,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existingPlan != null ? 'Planı Düzenle' : 'Yeni Plan Oluştur',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: textM),
            textAlign: TextAlign.center,
          ),
          AppSizes.hBoxHigh,
          TextField(
            controller: _titleController,
            style: TextStyle(color: textM),
            decoration: InputDecoration(
              labelText: 'Plan Başlığı',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
            ),
          ),
          AppSizes.hBoxNormal,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _presentDatePicker,
                  icon: const Icon(
                    LucideIcons.calendarDays,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  label: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(color: textM),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.rMedium),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSizes.hBoxHigh,
          ElevatedButton(
            onPressed: _savePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.pMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
            ),
            child: Text(
              widget.existingPlan != null ? 'Güncelle' : 'Kaydet',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          AppSizes.hBoxHigh,
        ],
      ),
    );
  }
}
