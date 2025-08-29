import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../services/notification_service.dart';
import '../../../sleep/presentation/theme/sleep_colors.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';

class ProfileHomeScreen extends ConsumerStatefulWidget {
  const ProfileHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends ConsumerState<ProfileHomeScreen> {
  final NotificationService _notificationService = NotificationService();

  // Personal info controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedSex = 'Male';

  bool _sustainabilityTipsEnabled = false;
  bool _healthRemindersEnabled = false;
  bool _notificationsAllowed = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadPersonalInfo();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightController.text = prefs.getString('profile_weight') ?? '';
      _heightController.text = prefs.getString('profile_height') ?? '';
      _ageController.text = prefs.getString('profile_age') ?? '';
      _selectedSex = prefs.getString('profile_sex') ?? 'Male';
    });
  }

  Future<void> _savePersonalInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_weight', _weightController.text);
    await prefs.setString('profile_height', _heightController.text);
    await prefs.setString('profile_age', _ageController.text);
    await prefs.setString('profile_sex', _selectedSex);
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    final bool allowed = await _notificationService.areNotificationsEnabled();

    // Load saved notification preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool sustainabilityEnabled =
        prefs.getBool('sustainability_tips_enabled') ?? false;
    final bool healthEnabled =
        prefs.getBool('health_reminders_enabled') ?? false;

    if (mounted) {
      setState(() {
        _notificationsAllowed = allowed;
        _sustainabilityTipsEnabled = sustainabilityEnabled;
        _healthRemindersEnabled = healthEnabled;
      });
    }
  }

  Future<void> _saveNotificationPreference(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserEntity?> userAsyncValue =
        ref.watch(currentUserProvider);
    final UserEntity? user = userAsyncValue.value;
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline, color: textColor),
            onPressed: () => _showProfileGuide(context),
          ),
        ],
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
                    backgroundColor: accentColor.withValues(alpha: 0.1),
                    child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              width: 128,
                              height: 128,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 64,
                                  color: accentColor,
                                );
                              },
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      accentColor),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 64,
                            color: accentColor,
                          ),
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

            // Personal Info Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Personal Info',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSex,
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem(
                                  value: 'Male', child: Text('Male')),
                              DropdownMenuItem(
                                  value: 'Female', child: Text('Female')),
                              DropdownMenuItem(
                                  value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedSex = value;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Sex',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _savePersonalInfo();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Personal info saved!'),
                                backgroundColor: accentColor,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
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
                children: const <Widget>[
                  _StatCard(title: 'Total Points', value: '1,250'),
                  SizedBox(width: 8),
                  _StatCard(title: 'Achievements', value: '15'),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: const <Widget>[
                  _StatCard(title: 'Streak', value: '30 Days'),
                  SizedBox(width: 8),
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
            // Notification Settings Section
            _buildNotificationSection(),
            const SizedBox(height: 16),
            _QuickSettingTile(
              icon: Icons.notifications_active,
              label: 'Notification Settings',
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              ),
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
                    actions: <Widget>[
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

  Widget _buildNotificationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsAllowed
              ? SleepColors.successGreen
              : SleepColors.errorRed,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                _notificationsAllowed
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _notificationsAllowed
                    ? SleepColors.successGreen
                    : SleepColors.errorRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Notification Settings',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_notificationsAllowed) ...<Widget>[
            Text(
              'Enable notifications to receive sustainability tips and health reminders',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final bool granted =
                      await _notificationService.requestPermissions();
                  if (granted) {
                    setState(() => _notificationsAllowed = true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SleepColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Enable Notifications'),
              ),
            ),
          ] else ...<Widget>[
            // Sustainability Tips
            _buildNotificationOption(
              title: 'Daily Sustainability Tips',
              description:
                  'Get tips for eco-friendly living throughout the day (automatic)',
              value: _sustainabilityTipsEnabled,
              onChanged: (bool value) async {
                setState(() => _sustainabilityTipsEnabled = value);
                await _saveNotificationPreference(
                    'sustainability_tips_enabled', value);
                // Note: Tips are now automatic when the app starts
                if (!value) {
                  await _notificationService
                      .cancelNotificationsByChannel('sustainability_tips');
                }
              },
            ),

            const SizedBox(height: 16),

            // Health Reminders
            _buildNotificationOption(
              title: 'Health Reminders',
              description:
                  'Get reminded about wellness and self-care (automatic)',
              value: _healthRemindersEnabled,
              onChanged: (bool value) async {
                setState(() => _healthRemindersEnabled = value);
                await _saveNotificationPreference(
                    'health_reminders_enabled', value);
                // Note: Reminders are now automatic when the app starts
                if (!value) {
                  await _notificationService
                      .cancelNotificationsByChannel('health_reminders');
                }
              },
            ),

            const SizedBox(height: 24),

            // Simple test notification button (optional)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await _notificationService.sendTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Test notification sent!'),
                      backgroundColor: SleepColors.successGreen,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: SleepColors.primaryGreen,
                  side: BorderSide(color: SleepColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Send Test Notification'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: SleepColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: SleepColors.primaryGreen,
        ),
      ],
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

void _showProfileGuide(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Profile Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Welcome to your profile! Here\'s how to manage your account:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('👤 Personal Information'),
              Text('• Update your profile details and preferences'),
              Text('• Manage your account settings and privacy'),
              Text('• View your personal statistics and achievements'),
              SizedBox(height: 8),
              Text('🏆 Achievements'),
              Text('• Track your sustainability milestones'),
              Text('• View badges and accomplishments'),
              Text('• Celebrate your progress and achievements'),
              SizedBox(height: 8),
              Text('🎯 Health Goals'),
              Text('• Set and manage your fitness and wellness goals'),
              Text('• Track your progress towards your objectives'),
              Text('• Get personalized recommendations'),
              SizedBox(height: 8),
              Text('🌱 Sustainability Dashboard'),
              Text('• Monitor your environmental impact'),
              Text('• Track your carbon footprint reduction'),
              Text('• View sustainability statistics and trends'),
              SizedBox(height: 8),
              Text('⚙️ Settings'),
              Text('• Customize your app preferences'),
              Text('• Manage notifications and privacy settings'),
              Text('• Access help and support options'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      );
    },
  );
}
