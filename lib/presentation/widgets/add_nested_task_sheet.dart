import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/nested_task_model.dart';
import '../../data/sources/database_helper.dart';

class AddNestedTaskSheet extends StatefulWidget {
  final int planId;
  final VoidCallback onTaskAdded;
  final NestedTaskModel? existingTask; // YENİ: Düzenleme için var olan görev

  const AddNestedTaskSheet({
    super.key,
    required this.planId,
    required this.onTaskAdded,
    this.existingTask,
  });

  @override
  State<AddNestedTaskSheet> createState() => _AddNestedTaskSheetState();
}

class _AddNestedTaskSheetState extends State<AddNestedTaskSheet> {
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // YENİ: Eğer görev düzenleniyorsa bilgileri doldur
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _detailController.text = widget.existingTask!.detail ?? '';
      if (widget.existingTask!.time != null) {
        final parts = widget.existingTask!.time!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _presentTimePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
    ).then((pickedTime) {
      if (pickedTime == null) return;
      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      UIHelpers.showCustomSnackBar(
        context,
        'Lütfen bir görev başlığı girin.',
        isError: true,
      );
      return;
    }

    String? formattedTime;
    if (_selectedTime != null) {
      final h = _selectedTime!.hour.toString().padLeft(2, '0');
      final m = _selectedTime!.minute.toString().padLeft(2, '0');
      formattedTime = '$h:$m';
    }

    final newTask = NestedTaskModel(
      id: widget.existingTask?.id,
      planId: widget.planId,
      title: _titleController.text.trim(),
      detail: _detailController.text.trim().isNotEmpty
          ? _detailController.text.trim()
          : null,
      time: formattedTime,
      isCompleted: widget.existingTask?.isCompleted ?? 0,
    );

    // YENİ: Varsa Güncelle, Yoksa Ekle
    if (widget.existingTask != null) {
      await DatabaseHelper.instance.updateNestedTask(newTask);
      if (mounted) UIHelpers.showCustomSnackBar(context, 'Görev güncellendi.');
    } else {
      await DatabaseHelper.instance.insertNestedTask(newTask);
      if (mounted) UIHelpers.showCustomSnackBar(context, 'Yeni görev eklendi.');
    }

    widget.onTaskAdded();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final borderColor = isDark ? AppColors.glassBorder : Colors.grey.shade300;

    String timeText = 'Saat Ekle (İsteğe Bağlı)';
    if (_selectedTime != null) {
      final h = _selectedTime!.hour.toString().padLeft(2, '0');
      final m = _selectedTime!.minute.toString().padLeft(2, '0');
      timeText = '$h:$m';
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSizes.pLarge,
        right: AppSizes.pLarge,
        top: AppSizes.pLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existingTask != null ? 'Görevi Düzenle' : 'Alt Görev Ekle',
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
              labelText: 'Görev Başlığı',
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
          TextField(
            controller: _detailController,
            style: TextStyle(color: textM),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Detay (Opsiyonel)',
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
          OutlinedButton.icon(
            onPressed: _presentTimePicker,
            icon: const Icon(
              LucideIcons.clock,
              color: AppColors.aiHighlight,
              size: 20,
            ),
            label: Text(timeText, style: TextStyle(color: textM)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
            ),
          ),
          AppSizes.hBoxHigh,
          ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.pMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
            ),
            child: Text(
              widget.existingTask != null ? 'Güncelle' : 'Kaydet',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          AppSizes.hBoxHigh,
        ],
      ),
    );
  }
}
