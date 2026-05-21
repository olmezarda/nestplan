import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/format_model.dart';
import '../../data/models/format_field_model.dart';
import '../../data/sources/database_helper.dart';
import '../widgets/add_format_sheet.dart';
import '../widgets/format_card.dart';

class FormatsScreen extends StatefulWidget {
  const FormatsScreen({super.key});

  @override
  State<FormatsScreen> createState() => _FormatsScreenState();
}

class _FormatsScreenState extends State<FormatsScreen> {
  List<FormatModel> _formats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormats();
  }

  Future<void> _loadFormats() async {
    final formats = await DatabaseHelper.instance.getFormats();
    if (mounted) {
      setState(() {
        _formats = formats;
        _isLoading = false;
      });
    }
  }

  void _showFormatSheet({FormatModel? format, List<FormatFieldModel>? fields}) {
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
      builder: (ctx) => AddFormatSheet(
        existingFormat: format,
        existingFields: fields,
        onFormatSaved: _loadFormats,
      ),
    );
  }

  void _deleteFormat(FormatModel format) async {
    final confirm = await UIHelpers.showConfirmDialog(
      context,
      'Formatı Sil',
      'Bu taslağı silmek istediğinize emin misiniz?',
    );
    if (confirm && mounted) {
      await DatabaseHelper.instance.deleteFormat(format.id!);
      _loadFormats();
    }
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
        title: Text('Formatlarım', style: TextStyle(color: textM)),
        scrolledUnderElevation: 0,
        backgroundColor: bg,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _formats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.layoutTemplate,
                    size: 64,
                    color: textS.withValues(alpha: 0.5),
                  ),
                  AppSizes.hBoxNormal,
                  Text(
                    'Henüz özel bir format yok.',
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
              itemCount: _formats.length,
              itemBuilder: (context, index) {
                final format = _formats[index];
                return FormatCard(
                  format: format,
                  onEdit: (f, fields) =>
                      _showFormatSheet(format: f, fields: fields),
                  onDelete: () => _deleteFormat(format),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormatSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
