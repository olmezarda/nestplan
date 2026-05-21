import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final bool isDark;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surface : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.glassBorder : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
