import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.aiHighlight,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textMain),
        titleTextStyle: TextStyle(
          color: AppColors.textMain,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            bodyLarge: const TextStyle(color: AppColors.textMain),
            bodyMedium: const TextStyle(color: AppColors.textSecondary),
            titleLarge: const TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.rMedium)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.rLarge),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.rMedium)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.aiHighlight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textMainLight),
        titleTextStyle: TextStyle(
          color: AppColors.textMainLight,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            bodyLarge: const TextStyle(color: AppColors.textMainLight),
            bodyMedium: const TextStyle(color: AppColors.textSecondaryLight),
            titleLarge: const TextStyle(
              color: AppColors.textMainLight,
              fontWeight: FontWeight.bold,
            ),
          ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.rMedium)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.rLarge),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.rMedium)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        elevation: 8,
      ),
    );
  }
}
