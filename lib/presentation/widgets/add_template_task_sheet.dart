import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/template_task_model.dart';
import '../../data/models/format_model.dart';
import '../../data/models/format_field_model.dart';
import '../../data/sources/database_helper.dart';

class AddTemplateTaskSheet extends StatefulWidget {
  final int templateId;
  final VoidCallback onTaskAdded;
  final TemplateTaskModel? existingTask;

  const AddTemplateTaskSheet({
    super.key,
    required this.templateId,
    required this.onTaskAdded,
    this.existingTask,
  });

  @override
  State<AddTemplateTaskSheet> createState() => _AddTemplateTaskSheetState();
}

class _AddTemplateTaskSheetState extends State<AddTemplateTaskSheet> {
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  final Map<String, TextEditingController> _dynamicControllers = {};

  List<FormatModel> _formats = [];
  List<FormatFieldModel> _formatFields = [];
  FormatModel? _selectedFormat;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.existingTask?.title ?? '';
    _detailController.text = widget.existingTask?.detail ?? '';
    if (widget.existingTask?.time != null) {
      final parts = widget.existingTask!.time!.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    _loadFormats();
  }

  Future<void> _loadFormats() async {
    final formats = await DatabaseHelper.instance.getFormats();
    setState(() => _formats = formats);
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) return;

    String finalDetail = _detailController.text.trim();
    if (_selectedFormat != null) {
      List<String> detailParts = [];
      _dynamicControllers.forEach((key, controller) {
        if (controller.text.trim().isNotEmpty) {
          detailParts.add('$key: ${controller.text.trim()}');
        }
      });
      finalDetail = detailParts.join(' | ');
    }

    String? formattedTime;
    if (_selectedTime != null) {
      formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    }

    final newTask = TemplateTaskModel(
      id: widget.existingTask?.id,
      templateId: widget.templateId,
      title: _titleController.text.trim(),
      detail: finalDetail.isNotEmpty ? finalDetail : null,
      time: formattedTime,
    );

    if (widget.existingTask != null) {
      await DatabaseHelper.instance.updateTemplateTask(newTask);
    } else {
      await DatabaseHelper.instance.insertTemplateTask(newTask);
    }
    if (!mounted) return;
    Navigator.pop(context);
    widget.onTaskAdded();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surface : AppColors.surfaceLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSizes.pLarge,
        right: AppSizes.pLarge,
        top: AppSizes.pLarge,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingTask != null
                  ? 'İçeriği Düzenle'
                  : 'Şablona İçerik Ekle',
              style: TextStyle(
                color: textM,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSizes.hBoxHigh,
            if (widget.existingTask == null && _formats.isNotEmpty) ...[
              DropdownButtonFormField<FormatModel>(
                initialValue: _selectedFormat,
                dropdownColor: bg,
                style: TextStyle(color: textM),
                decoration: InputDecoration(
                  labelText: 'Hazır Format Seç',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.rMedium),
                  ),
                ),
                items: _formats
                    .map(
                      (f) => DropdownMenuItem(value: f, child: Text(f.title)),
                    )
                    .toList(),
                onChanged: (val) async {
                  if (val != null) {
                    final fields = await DatabaseHelper.instance
                        .getFormatFields(val.id!);
                    _dynamicControllers.clear();
                    for (var field in fields) {
                      _dynamicControllers[field.fieldName] =
                          TextEditingController();
                    }
                    setState(() {
                      _selectedFormat = val;
                      _formatFields = fields;
                    });
                  }
                },
              ),
              AppSizes.hBoxNormal,
            ],
            TextField(
              controller: _titleController,
              style: TextStyle(color: textM),
              decoration: InputDecoration(
                labelText: 'Görev Başlığı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rMedium),
                ),
              ),
            ),
            AppSizes.hBoxNormal,
            if (_selectedFormat == null)
              TextField(
                controller: _detailController,
                style: TextStyle(color: textM),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Detay',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.rMedium),
                  ),
                ),
              )
            else ...[
              ..._formatFields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextField(
                    controller: _dynamicControllers[field.fieldName],
                    style: TextStyle(color: textM),
                    decoration: InputDecoration(
                      labelText: field.fieldName,
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
            AppSizes.hBoxNormal,
            OutlinedButton.icon(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );
                if (time != null) setState(() => _selectedTime = time);
              },
              icon: const Icon(
                LucideIcons.clock,
                color: AppColors.aiHighlight,
                size: 20,
              ),
              label: Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
                    : 'Saat Ekle',
                style: TextStyle(color: textM),
              ),
            ),
            AppSizes.hBoxHigh,
            ElevatedButton(
              onPressed: _saveTask,
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
}
