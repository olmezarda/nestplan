import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../main.dart';
import 'auth_screen.dart';
import '../widgets/profile_card.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _username = '';
  bool _isDark = true;
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Kullanıcı';
      _isDark = prefs.getBool('is_dark_mode') ?? true;
    });
  }

  void _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    setState(() => _isDark = value);
    themeModeNotifier.updateTheme(value ? ThemeMode.dark : ThemeMode.light);
  }

  void _changePassword() async {
    final newPass = _newPasswordController.text.trim();
    if (newPass.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPass);
    _newPasswordController.clear();
    if (mounted) {
      Navigator.pop(context);
      UIHelpers.showCustomSnackBar(context, 'Şifreniz başarıyla değiştirildi.');
    }
  }

  void _showChangePasswordDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
        title: const Text('Şifre Değiştir'),
        content: TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Yeni Şifre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _changePassword,
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    final confirm = await UIHelpers.showConfirmDialog(
      context,
      'Çıkış Yap',
      'Oturumu kapatmak istediğinize emin misiniz?',
      confirmText: 'Çıkış Yap',
    );

    if (confirm && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pMedium),
        children: [
          ProfileCard(username: _username),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    LucideIcons.moon,
                    color: _isDark
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  title: const Text('Koyu Tema'),
                  value: _isDark,
                  onChanged: _toggleTheme,
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: LucideIcons.key,
                  title: 'Şifre Değiştir',
                  onTap: _showChangePasswordDialog,
                  iconColor: AppColors.accentGold,
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: LucideIcons.logOut,
                  title: 'Güvenli Çıkış Yap',
                  onTap: _logout,
                  iconColor: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
