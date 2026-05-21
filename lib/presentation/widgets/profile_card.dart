import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class ProfileCard extends StatelessWidget {
  final String username;

  const ProfileCard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(LucideIcons.user, color: AppColors.background),
        ),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text('Aktif Hesap'),
      ),
    );
  }
}
