import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

final ThemeModeNotifier themeModeNotifier = ThemeModeNotifier();

class ThemeModeNotifier extends ValueNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void updateTheme(ThemeMode themeMode) {
    value = themeMode;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final isDarkMode = prefs.getBool('is_dark_mode') ?? true;

  themeModeNotifier.updateTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  await initializeDateFormatting('tr_TR', null);
  runApp(NestPlanApp(hasSeenOnboarding: hasSeenOnboarding));
}

class NestPlanApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const NestPlanApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr', 'TR')],
          locale: const Locale('tr', 'TR'),
          debugShowCheckedModeBanner: false,
          title: 'Nest Plan',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: hasSeenOnboarding
              ? const AuthScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
