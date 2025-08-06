import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? const Color(0xFF141f18) : const Color(0xFFF8FBFA);
    final Color cardColor = isDark ? const Color(0xFF1e2f25) : Colors.white;
    final Color borderColor =
        isDark ? const Color(0xFF3c5d49) : const Color(0xFFD1E6D9);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    final Color accentColor =
        isDark ? const Color(0xFF94e0b2) : const Color(0xFF51946c);
    final Color tileBg =
        isDark ? const Color(0xFF1e2f25) : const Color(0xFFE8F2EC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
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
            _SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Customize your notification settings',
              trailing: Switch(
                value: true,
                onChanged: (bool val) {},
                activeColor: accentColor,
                inactiveTrackColor: tileBg,
              ),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
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
  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.trailing,
      this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? const Color(0xFF1e2f25) : const Color(0xFFE8F2EC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    final Color subtitleColor =
        isDark ? const Color(0xFF9bbfaa) : const Color(0xFF51946c);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: textColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 14)),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ] else ...<Widget>[
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
