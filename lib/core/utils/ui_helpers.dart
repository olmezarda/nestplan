import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class UIHelpers {
  static void showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    // Ekran boyutunu alıyoruz
    final size = MediaQuery.of(context).size;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Icon(LucideIcons.x, color: Colors.white70, size: 20),
            ),
          ],
        ),
        backgroundColor: (isError ? AppColors.error : AppColors.success)
            .withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        // YENİ: Alttan ekran boyu kadar itip üstte görünmesini sağlıyoruz
        margin: EdgeInsets.only(
          bottom: size.height - 160, // Üstten biraz boşluk bırakacak şekilde
          left: AppSizes.pLarge,
          right: AppSizes.pLarge,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rMedium),
        ),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String content, {
    String confirmText = 'Sil',
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surface : AppColors.surfaceLight;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        title: Text(title, style: TextStyle(color: textM)),
        content: Text(content, style: TextStyle(color: textS)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('İptal', style: TextStyle(color: textS)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
