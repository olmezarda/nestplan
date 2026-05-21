import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/format_model.dart';
import '../../data/models/format_field_model.dart';
import '../../data/sources/database_helper.dart';

class AddFormatSheet extends StatefulWidget {
  final FormatModel? existingFormat;
  final List<FormatFieldModel>? existingFields;
  final VoidCallback onFormatSaved;

  const AddFormatSheet({
    super.key,
    this.existingFormat,
    this.existingFields,
    required this.onFormatSaved,
  });

  @override
  State<AddFormatSheet> createState() => _AddFormatSheetState();
}

class _AddFormatSheetState extends State<AddFormatSheet> {
  late TextEditingController _titleController;
  late TextEditingController _fieldsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingFormat?.title ?? '',
    );
    _fieldsController = TextEditingController(
      text: widget.existingFields != null
          ? widget.existingFields!.map((e) => e.fieldName).join(', ')
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fieldsController.dispose();
    super.dispose();
  }

  Future<void> _saveFormat() async {
    if (_titleController.text.trim().isEmpty ||
        _fieldsController.text.trim().isEmpty) {
      UIHelpers.showCustomSnackBar(
        context,
        'Lütfen tüm alanları doldurun.',
        isError: true,
      );
      return;
    }

    int formatId;
    if (widget.existingFormat != null) {
      formatId = widget.existingFormat!.id!;
      await DatabaseHelper.instance.updateFormat(
        FormatModel(id: formatId, title: _titleController.text.trim()),
      );
      await DatabaseHelper.instance.deleteFormatFields(formatId);
    } else {
      formatId = await DatabaseHelper.instance.insertFormat(
        FormatModel(title: _titleController.text.trim()),
      );
    }

    final fields = _fieldsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    for (var field in fields) {
      await DatabaseHelper.instance.insertFormatField(
        FormatFieldModel(formatId: formatId, fieldName: field),
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
    widget.onFormatSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

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
            widget.existingFormat != null
                ? 'Formatı Düzenle'
                : 'Yeni Format Taslağı',
            style: TextStyle(
              color: textM,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          AppSizes.hBoxHigh,
          TextField(
            controller: _titleController,
            style: TextStyle(color: textM),
            decoration: InputDecoration(
              labelText: 'Format Adı (Örn: Fitness)',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                ),
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
            controller: _fieldsController,
            style: TextStyle(color: textM),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Alanlar (Virgülle ayırın)',
              hintText: 'Örn: Hareket, Set, Tekrar, Ağırlık',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
            ),
          ),
          AppSizes.hBoxHigh,
          ElevatedButton(
            onPressed: _saveFormat,
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
    );
  }
}
