import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/onboarding_pages.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Deneyimini Özelleştir',
      description:
          'Uygulamayı kendi kullanım tarzına göre şekillendir. Tema seçimini anında değiştir ve sana en uygun görünümü kullan.',
      icon: LucideIcons.palette,
      color: AppColors.accentGold,
      features: [
        'Koyu & Açık Tema',
        'Modern ve sade arayüz',
        'Odak artıran tasarım',
      ],
    ),
    OnboardingData(
      title: 'Akıllı Plan Yönetimi',
      description:
          'Büyük hedeflerini organize et. Ana planlar oluştur, alt görevler ekle ve tüm sürecini tek ekrandan yönet.',
      icon: LucideIcons.layers,
      color: AppColors.primary,
      features: [
        'Ana Plan > Alt Görev sistemi',
        'Günlük & tarih aralıklı planlar',
        'Hızlı düzenleme ve takip',
      ],
    ),
    OnboardingData(
      title: 'Ana Sayfa',
      description:
          'Tüm aktif planlarını tek merkezde görüntüle. Günlük akışını filtrele, yaklaşan görevlerini takip et ve eksik adımları anında fark et.',
      icon: LucideIcons.layoutDashboard,
      color: AppColors.aiHighlight,
      features: [
        'Bugün / Günlük / Aralıklı filtreleri',
        'Akıllı arama sistemi',
        'Eksik alt görev uyarıları',
      ],
    ),
    OnboardingData(
      title: 'Formatlar',
      description:
          'Kendi çalışma sistemini oluştur. Spor, diyet, çalışma veya kişisel rutinlerin için özel veri alanları tasarla.',
      icon: LucideIcons.sparkles,
      color: AppColors.accentGold,
      features: [
        'Özel alan oluşturma',
        'Set, tekrar, kalori gibi veri girişleri',
        'Hazır şablon kategorileri',
      ],
    ),
    OnboardingData(
      title: 'Şablonlar',
      description:
          'Tekrar eden rutinlerini bir kez oluştur, istediğin günlere otomatik uygula. Planlamayı tamamen otomatik hale getir.',
      icon: LucideIcons.copyCheck,
      color: AppColors.primary,
      features: [
        'Rutin şablon sistemi',
        'Takvim üzerinden toplu atama',
        'Otomatik görev detayları',
      ],
    ),
    OnboardingData(
      title: 'Ayarlar & Kontrol',
      description:
          'Uygulamanın tüm deneyimini yönet. Tema tercihlerini, görünümünü ve kullanım ayarlarını dilediğin gibi düzenle.',
      icon: LucideIcons.settings2,
      color: AppColors.aiHighlight,
      features: [
        'Tema yönetimi',
        'Profil & deneyim ayarları',
        'Kişiselleştirilebilir yapı',
      ],
    ),
    OnboardingData(
      title: 'Hazırsın',
      description:
          'Artık tüm planlarını daha organize, daha düzenli ve daha verimli şekilde yönetebilirsin.',
      icon: LucideIcons.rocket,
      color: AppColors.primary,
      features: [
        'Daha yüksek odak',
        'Düzenli rutin sistemi',
        'Tam kontrol sende',
      ],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.bgLight,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pLarge,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${_currentPage + 1}/${_pages.length}',
                    key: ValueKey(_currentPage),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Geç',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = _pages[index];

                if (index == 0) {
                  return ThemeSelectionPage(isDark: isDark);
                }

                if (index % 2 == 0) {
                  return LeftAlignedPage(page: page, isDark: isDark);
                } else {
                  return CenterAlignedPage(page: page, isDark: isDark);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pLarge,
              0,
              AppSizes.pLarge,
              AppSizes.pLarge,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 26 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.surface
                                  : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.rLarge),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Uygulamaya Başla'
                          : 'Devam Et',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
