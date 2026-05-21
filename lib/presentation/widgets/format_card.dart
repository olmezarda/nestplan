import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/format_model.dart';
import '../../data/models/format_field_model.dart';
import '../../data/sources/database_helper.dart';

class FormatCard extends StatelessWidget {
  final FormatModel format;
  final Function(FormatModel, List<FormatFieldModel>) onEdit;
  final VoidCallback onDelete;

  const FormatCard({
    super.key,
    required this.format,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.pSmall),
        child: ExpansionTile(
          leading: const Icon(
            LucideIcons.layoutTemplate,
            color: AppColors.aiHighlight,
          ),
          title: Text(
            format.title,
            style: TextStyle(color: textM, fontWeight: FontWeight.bold),
          ),
          children: [
            FutureBuilder<List<FormatFieldModel>>(
              future: DatabaseHelper.instance.getFormatFields(format.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final fields = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        children: fields
                            .map(
                              (f) => Chip(
                                label: Text(
                                  f.fieldName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: isDark
                                    ? AppColors.surface
                                    : Colors.grey.shade200,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => onEdit(format, fields),
                            icon: const Icon(
                              LucideIcons.edit3,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            label: const Text(
                              'Düzenle',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(
                              LucideIcons.trash2,
                              color: AppColors.error,
                              size: 16,
                            ),
                            label: const Text(
                              'Sil',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
