import 'package:flutter/material.dart';
import '../pages/data_sync_page.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            _SectionHeader(title: 'Account'),
            _SettingsTile(
              icon: Icons.person,
              title: 'Profile',
              subtitle: 'Edit your profile information',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/edit'),
            ),
            _SettingsTile(
              icon: Icons.lock,
              title: 'Password',
              subtitle: 'Change your password',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/password'),
            ),
            _SettingsTile(
              icon: Icons.shield,
              title: 'Privacy',
              subtitle: 'Manage your privacy settings',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/privacy'),
            ),
            _SettingsTile(
              icon: Icons.storage,
              title: 'Data Management',
              subtitle: 'Export or delete your data',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/data'),
            ),
            _SettingsTile(
              icon: Icons.cloud_sync,
              title: 'Data Synchronization',
              subtitle: 'Sync local data to cloud storage',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const DataSyncPage(),
                  ),
                );
              },
            ),
            _SectionHeader(title: 'App Preferences'),
            _SettingsTile(
              icon: Icons.straighten,
              title: 'Units',
              subtitle: 'Choose between metric and imperial units',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/units'),
            ),
            _SettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Select your preferred language',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/language'),
            ),
            _SettingsTile(
              icon: Icons.wb_sunny,
              title: 'Theme',
              subtitle: 'Switch between light, dark, or auto theme',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/theme'),
            ),
            _SectionHeader(title: 'Sustainability'),
            _SettingsTile(
              icon: Icons.eco,
              title: 'Carbon Tracking',
              subtitle: 'Configure your carbon tracking preferences',
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/carbon'),
            ),
            _SettingsTile(
              icon: Icons.emoji_events,
              title: 'Eco-Challenges',
              subtitle: 'Join eco-challenges and track your progress',
              onTap: () => Navigator.of(context)
                  .pushNamed('/profile/settings/challenges'),
            ),
            _SettingsTile(
              icon: Icons.access_time,
              title: 'Sustainability Reminders',
              subtitle: 'Set reminders for sustainable health habits',
              onTap: () => Navigator.of(context)
                  .pushNamed('/profile/settings/reminders'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const _SettingsTile({
      required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap,
      this.trailing,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ] else ...<Widget>[
              Icon(Icons.arrow_forward_ios, 
                   size: 18, 
                   color: colorScheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}
