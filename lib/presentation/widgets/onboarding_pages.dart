import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../main.dart';

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}

class CenterAlignedPage extends StatelessWidget {
  final OnboardingData page;
  final bool isDark;

  const CenterAlignedPage({
    super.key,
    required this.page,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.pLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withValues(alpha: 0.12),
              border: Border.all(
                color: page.color.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.12),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(child: Icon(page.icon, size: 64, color: page.color)),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 34),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: page.features.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.checkCircle2, size: 16, color: page.color),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class LeftAlignedPage extends StatelessWidget {
  final OnboardingData page;
  final bool isDark;

  const LeftAlignedPage({super.key, required this.page, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.pLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.rLarge),
            ),
            child: Icon(page.icon, size: 48, color: page.color),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),
          ...page.features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: page.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ThemeSelectionPage extends StatelessWidget {
  final bool isDark;

  const ThemeSelectionPage({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textMain : AppColors.textMainLight;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.pLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.3),
              ),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.palette,
                size: 60,
                color: AppColors.accentGold,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Görünümünü Özelleştir',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Kullanım deneyimini sana uygun hale getir. İstediğin temayı seç ve uygulamayı anında kişiselleştir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 42),
          Row(
            children: [
              _buildThemeCard(
                ThemeMode.dark,
                LucideIcons.moonStar,
                'Koyu Tema',
                'Gece kullanımına uygun',
                isDark,
              ),
              const SizedBox(width: 16),
              _buildThemeCard(
                ThemeMode.light,
                LucideIcons.sunMedium,
                'Açık Tema',
                'Temiz ve ferah görünüm',
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    ThemeMode mode,
    IconData icon,
    String label,
    String subtitle,
    bool isDark,
  ) {
    final isSelected =
        (mode == ThemeMode.dark && isDark) ||
        (mode == ThemeMode.light && !isDark);

    return Expanded(
      child: GestureDetector(
        onTap: () => themeModeNotifier.updateTheme(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.rLarge),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.glassBorder,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 28, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.textMain : AppColors.textMainLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
