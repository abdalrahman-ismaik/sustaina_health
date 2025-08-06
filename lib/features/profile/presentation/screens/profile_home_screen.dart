import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    final user = userAsyncValue.value;
    print(
        'DEBUG ProfileScreen: Building with user: ${user?.displayName ?? 'null'} (${user?.email ?? 'no email'})');
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? const Color(0xFF141f18) : const Color(0xFFF8FBFA);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    final Color accentColor =
        isDark ? const Color(0xFF94e0b2) : const Color(0xFF51946c);
    final Color badgeBg =
        isDark ? const Color(0xFF2a4133) : const Color(0xFFE8F2EC);

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
          'Profile',
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
            // User Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBw9_JpxeDSu4VKkIeDY9KjNmyJQ8CVOZSU8N8cYKmBHvz6KHFmN7_G2GO_PodfOOWMGM-QzuwFo4TeXILm8EsITKn8ZT-A2q41NZGQg6VIspvz_rA2dMiF7VoBO--UKa9UUxWD9dw7uPcDgbHkiBY-CUh_NEEupbXbgQPyqJLrM20vMe4UZO57czhNuAj-yPIYZYyazcx8_8tZo2_j3WFf8p-K46684W3ZPDZbOJp3paE49Vjatm0-vTTFFCNcL3sKCraIu8mkGIcn'),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.displayName ?? 'User',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  Text('Premium Member',
                      style: TextStyle(fontSize: 16, color: accentColor)),
                  Text(user?.email ?? 'No email',
                      style: TextStyle(fontSize: 14, color: accentColor)),
                ],
              ),
            ),
            // Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.verified, color: accentColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Sustainability Champion',
                          style: TextStyle(color: textColor, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Statistics',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const <Widget>[
                  _StatCard(title: 'Total Points', value: '1,250'),
                  _StatCard(title: 'Achievements', value: '15'),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const <Widget>[
                  _StatCard(title: 'Streak', value: '30 Days'),
                  _StatCard(title: 'Carbon Reduced', value: '250 kg'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Quick Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Quick Settings',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ),
            const SizedBox(height: 8),
            _QuickSettingTile(
              icon: Icons.notifications,
              label: 'Notifications',
              trailing: Switch(
                value: true,
                onChanged: (bool val) {},
                activeColor: Color(0xFF38e07b),
                inactiveTrackColor: Color(0xFFE8F2EC),
              ),
              onTap: null,
            ),
            _QuickSettingTile(
              icon: Icons.lock,
              label: 'Privacy',
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/privacy'),
            ),
            _QuickSettingTile(
              icon: Icons.settings,
              label: 'App Preferences',
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/settings/app'),
            ),
            _QuickSettingTile(
              icon: Icons.logout,
              label: 'Logout',
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                // Show confirmation dialog
                final bool? shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  try {
                    await ref.read(authRepositoryProvider).logout();
                    // Invalidate all auth-related providers to ensure clean state
                    ref.invalidate(authStateProvider);
                    ref.invalidate(currentUserProvider);
                    print('DEBUG: Logout successful, providers invalidated');
                    // Navigation will be handled automatically by the auth state change
                  } catch (e) {
                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to logout: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1e2f25) : Colors.white;
    final Color borderColor =
        isDark ? const Color(0xFF3c5d49) : const Color(0xFFD1E6D9);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: <Widget>[
            Text(title,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _QuickSettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  const _QuickSettingTile(
      {required this.icon,
      required this.label,
      required this.trailing,
      this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? const Color(0xFF1e2f25) : const Color(0xFFE8F2EC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: textColor),
            const SizedBox(width: 16),
            Expanded(
              child:
                  Text(label, style: TextStyle(color: textColor, fontSize: 16)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
