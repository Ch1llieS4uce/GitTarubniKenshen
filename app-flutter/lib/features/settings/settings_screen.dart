import 'package:flutter/material.dart';

import '../../design_system.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => GlassScaffold(
        appBar: const GlassAppBar(title: 'Settings'),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'Dark blue with orange CTA',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacy',
                subtitle: 'Manage account and permissions',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'BARYABest',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GlassIconButton(
            icon: icon,
            onPressed: null,
            size: 44,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

