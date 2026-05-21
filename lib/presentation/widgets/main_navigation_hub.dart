import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/templates_screen.dart';
import '../screens/formats_screen.dart';

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
  late final List<Widget> _screens = [
    HomeScreen(key: homeKey),
    const FormatsScreen(),
    const TemplatesScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      homeKey.currentState?.refreshPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onItemTapped(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutTemplate),
            label: 'Format Ayarla',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.copy),
            label: 'Şablon Yarat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
