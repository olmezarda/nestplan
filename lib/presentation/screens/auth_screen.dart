import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../widgets/main_navigation_hub.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegistered = false;
  bool _isForgotMode = false;
  String _savedUsername = '';
  String _savedPassword = '';
  String _savedQuestion = '';
  String _savedAnswer = '';

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedQuestion = 'İlk evcil hayvanınızın adı nedir?';

  final List<String> _securityQuestions = [
    'İlk evcil hayvanınızın adı nedir?',
    'En sevdiğiniz öğretmenin soyadı nedir?',
    'Hangi şehirde doğdunuz?',
    'İlk arabanızın markası neydi?',
  ];

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    _savedQuestion = prefs.getString('security_question') ?? '';
    _savedAnswer = prefs.getString('security_answer') ?? '';

    if (username != null && password != null) {
      if (mounted) {
        setState(() {
          _isRegistered = true;
          _savedUsername = username;
          _savedPassword = password;
        });
      }
    }
  }

  void _handleAuth() async {
    final enteredPassword = _passwordController.text.trim();

    if (_isRegistered) {
      if (enteredPassword == _savedPassword) {
        _navigateToHome();
      } else {
        UIHelpers.showCustomSnackBar(
          context,
          'Hatalı şifre, lütfen tekrar deneyin.',
          isError: true,
        );
      }
    } else {
      final enteredUsername = _usernameController.text.trim();
      final enteredAnswer = _answerController.text.trim();

      if (enteredUsername.isEmpty ||
          enteredPassword.isEmpty ||
          enteredAnswer.isEmpty) {
        UIHelpers.showCustomSnackBar(
          context,
          'Lütfen tüm alanları doldurun.',
          isError: true,
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', enteredUsername);
      await prefs.setString('password', enteredPassword);
      await prefs.setString('security_question', _selectedQuestion);
      await prefs.setString('security_answer', enteredAnswer.toLowerCase());
      _navigateToHome();
    }
  }

  void _handleResetPassword() async {
    final enteredAnswer = _answerController.text.trim().toLowerCase();
    final newPassword = _newPasswordController.text.trim();

    if (enteredAnswer != _savedAnswer.toLowerCase()) {
      UIHelpers.showCustomSnackBar(
        context,
        'Güvenlik sorusunun cevabı hatalı!',
        isError: true,
      );
      return;
    }

    if (newPassword.isEmpty) {
      UIHelpers.showCustomSnackBar(
        context,
        'Lütfen yeni bir şifre girin.',
        isError: true,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPassword);

    if (!mounted) return;

    UIHelpers.showCustomSnackBar(context, 'Şifreniz başarıyla yenilendi.');
    setState(() {
      _isForgotMode = false;
      _passwordController.clear();
      _answerController.clear();
      _newPasswordController.clear();
      _checkRegistrationStatus();
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationHub()),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(AppSizes.rMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppSizes.rMedium),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surface : AppColors.surfaceLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Icon(
                  _isForgotMode
                      ? LucideIcons.keyRound
                      : LucideIcons.shieldCheck,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              AppSizes.hBoxHigh,
              Text(
                _isForgotMode
                    ? 'Şifre Sıfırlama'
                    : (_isRegistered
                          ? 'Hoş Geldin, $_savedUsername'
                          : 'Profilini Oluştur'),
                style: TextStyle(
                  color: textM,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              AppSizes.hBoxLow,
              Text(
                _isForgotMode
                    ? 'Güvenlik sorusunu yanıtlayarak şifreni sıfırla'
                    : (_isRegistered
                          ? 'Planlarına ulaşmak için şifreni gir'
                          : 'Uygulamayı kilitlemek için profilini belirle'),
                style: TextStyle(color: textS, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              AppSizes.hBoxHigh,
              Container(
                padding: const EdgeInsets.all(AppSizes.pLarge),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppSizes.rLarge),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: _isForgotMode
                    ? _buildForgotFields(textM)
                    : _buildAuthFields(textM, cardBg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthFields(Color textM, Color cardBg) {
    return Column(
      children: [
        if (!_isRegistered) ...[
          TextField(
            controller: _usernameController,
            style: TextStyle(color: textM),
            decoration: _buildInputDecoration(
              'Kullanıcı Adı',
              LucideIcons.user,
            ),
          ),
          AppSizes.hBoxNormal,
        ],
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textM),
          decoration: _buildInputDecoration('Şifre', LucideIcons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                color: AppColors.textSecondary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (!_isRegistered) ...[
          AppSizes.hBoxNormal,
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedQuestion,
            dropdownColor: cardBg,
            style: TextStyle(color: textM, fontSize: 14),
            decoration: _buildInputDecoration(
              'Güvenlik Sorusu Seçin',
              LucideIcons.helpCircle,
            ).copyWith(prefixIcon: null),
            items: _securityQuestions
                .map(
                  (q) => DropdownMenuItem(
                    value: q,
                    child: Text(q, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedQuestion = val!),
          ),
          AppSizes.hBoxNormal,
          TextField(
            controller: _answerController,
            style: TextStyle(color: textM),
            decoration: _buildInputDecoration(
              'Cevabınız',
              LucideIcons.messageSquare,
            ),
          ),
        ],
        AppSizes.hBoxHigh,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.pMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
            ),
            child: Text(
              _isRegistered ? 'Giriş Yap' : 'Kaydet ve Başla',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_isRegistered) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _isForgotMode = true),
            child: const Text(
              'Şifremi Unuttum',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForgotFields(Color textM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.pMedium),
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(AppSizes.rMedium),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.helpCircle,
                color: AppColors.primary,
                size: 20,
              ),
              AppSizes.wBoxNormal,
              Expanded(
                child: Text(
                  _savedQuestion,
                  style: TextStyle(color: textM, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        AppSizes.hBoxNormal,
        TextField(
          controller: _answerController,
          style: TextStyle(color: textM),
          decoration: _buildInputDecoration(
            'Cevabınız',
            LucideIcons.messageSquare,
          ),
        ),
        AppSizes.hBoxNormal,
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          style: TextStyle(color: textM),
          decoration: _buildInputDecoration('Yeni Şifre', LucideIcons.lock),
        ),
        AppSizes.hBoxHigh,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleResetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.pMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
              ),
            ),
            child: const Text(
              'Şifreyi Güncelle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isForgotMode = false),
            child: const Text(
              'Giriş Ekranına Dön',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
