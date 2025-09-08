import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../services/notification_service.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';
import '../../data/services/hybrid_profile_service.dart';
import '../../data/models/user_profile_model.dart';

class ProfileHomeScreen extends ConsumerStatefulWidget {
  const ProfileHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends ConsumerState<ProfileHomeScreen> {
  final NotificationService _notificationService = NotificationService();
  final HybridProfileService _profileService = HybridProfileService();

  // Personal info controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedSex = 'Male';

  bool _sustainabilityTipsEnabled = false;
  bool _healthRemindersEnabled = false;
  bool _notificationsAllowed = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadPersonalInfo();
    // Automatically sync local data to cloud on app start
    _syncLocalDataToCloud();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalInfo() async {
    try {
      // Try to load from hybrid service (which will check cloud first, then local)
      final UserProfile? profile = await _profileService.getUserProfile();
      
      if (profile != null) {
        setState(() {
          _weightController.text = profile.weight?.toString() ?? '';
          _heightController.text = profile.height?.toString() ?? '';
          _ageController.text = profile.age?.toString() ?? '';
          _selectedSex = profile.sex ?? 'Male';
        });
        print('✅ Personal info loaded from cloud storage');
      } else {
        // Fallback to SharedPreferences for backward compatibility
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          _weightController.text = prefs.getString('profile_weight') ?? '';
          _heightController.text = prefs.getString('profile_height') ?? '';
          _ageController.text = prefs.getString('profile_age') ?? '';
          _selectedSex = prefs.getString('profile_sex') ?? 'Male';
        });
        print('📁 Personal info loaded from local storage (fallback)');
      }
    } catch (e) {
      print('❌ Error loading personal info: $e');
      // Fallback to local storage if cloud fails
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _weightController.text = prefs.getString('profile_weight') ?? '';
        _heightController.text = prefs.getString('profile_height') ?? '';
        _ageController.text = prefs.getString('profile_age') ?? '';
        _selectedSex = prefs.getString('profile_sex') ?? 'Male';
      });
    }
  }

  Future<void> _savePersonalInfo() async {
    try {
      // Create UserProfile object
      final UserProfile profile = UserProfile(
        weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
        height: _heightController.text.isNotEmpty ? int.tryParse(_heightController.text) : null,
        age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
        sex: _selectedSex,
      );

      // Save using hybrid service (saves to both local and cloud)
      await _profileService.saveUserProfile(profile);
      
      // Also save to SharedPreferences for backward compatibility
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_weight', _weightController.text);
      await prefs.setString('profile_height', _heightController.text);
      await prefs.setString('profile_age', _ageController.text);
      await prefs.setString('profile_sex', _selectedSex);
      
      print('✅ Personal info saved to both local storage and Firestore cloud!');
    } catch (e) {
      print('❌ Error saving personal info: $e');
      // Fallback to SharedPreferences if hybrid service fails
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_weight', _weightController.text);
      await prefs.setString('profile_height', _heightController.text);
      await prefs.setString('profile_age', _ageController.text);
      await prefs.setString('profile_sex', _selectedSex);
      print('📁 Personal info saved to local storage (fallback)');
    }
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

  Future<void> _syncLocalDataToCloud() async {
    try {
      // Get current data from local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String weight = prefs.getString('profile_weight') ?? '';
      final String height = prefs.getString('profile_height') ?? '';
      final String age = prefs.getString('profile_age') ?? '';
      final String sex = prefs.getString('profile_sex') ?? 'Male';

      if (weight.isNotEmpty || height.isNotEmpty || age.isNotEmpty) {
        // Create UserProfile and sync to cloud
        final UserProfile profile = UserProfile(
          weight: weight.isNotEmpty ? double.tryParse(weight) : null,
          height: height.isNotEmpty ? int.tryParse(height) : null,
          age: age.isNotEmpty ? int.tryParse(age) : null,
          sex: sex,
        );

        await _profileService.saveUserProfile(profile);
        print('🔄 Successfully synced local personal data to cloud storage');
      }
    } catch (e) {
      print('❌ Error syncing local data to cloud: $e');
    }
  }

  Future<void> _showEditPersonalInfoDialog() async {
    String tempSelectedSex = _selectedSex;
    
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          title: const Text('Edit Personal Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    hintText: 'Enter your age',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: 'Enter your height',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: 'Enter your weight',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tempSelectedSex,
                  decoration: const InputDecoration(
                    labelText: 'Sex',
                  ),
                  items: <String>['Male', 'Female', 'Other']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      tempSelectedSex = newValue ?? 'Male';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update the main state with the dialog selection
                setState(() {
                  _selectedSex = tempSelectedSex;
                });
                
                try {
                  await _savePersonalInfo();
                  
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Personal information updated successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving information: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserEntity?> userAsyncValue =
        ref.watch(currentUserProvider);
    final UserEntity? user = userAsyncValue.value;
    print(
        'DEBUG ProfileScreen: Building with user: ${user?.displayName ?? 'null'} (${user?.email ?? 'no email'})');
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back arrow
        title: Text(
          'Profile',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline, color: cs.onSurface),
            onPressed: () => _showProfileGuide(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Enhanced User Profile Header
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    cs.primaryContainer,
                    cs.primaryContainer.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  // Profile Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: cs.shadow.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: cs.surface,
                      child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user.photoURL!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object error,
                                    StackTrace? stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 40,
                                    color: cs.primary,
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
                                        cs.primary),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 40,
                              color: cs.primary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user?.displayName ?? 'Welcome User',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Sustainability Champion',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.email ?? 'No email provided',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onPrimaryContainer.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Quick Action
                  IconButton(
                    onPressed: () {
                      // Navigate to edit profile
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: cs.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surface.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your Impact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // First row of stats
                  Row(
                    children: <Widget>[
                      _EnhancedStatCard(
                        icon: Icons.eco,
                        title: 'Carbon Saved',
                        value: _calculateCarbonSaved(),
                        unit: 'kg CO₂',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _EnhancedStatCard(
                        icon: Icons.local_fire_department,
                        title: 'Current Streak',
                        value: _getCurrentStreak(),
                        unit: 'days',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Second row of stats
                  Row(
                    children: <Widget>[
                      _EnhancedStatCard(
                        icon: Icons.fitness_center,
                        title: 'Workouts',
                        value: _getWorkoutCount(),
                        unit: 'total',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _EnhancedStatCard(
                        icon: Icons.emoji_events,
                        title: 'Achievements',
                        value: _getAchievementCount(),
                        unit: 'unlocked',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Personal Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Personal Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: _isSyncing ? null : () async {
                                setState(() {
                                  _isSyncing = true;
                                });
                                
                                try {
                                  await _syncLocalDataToCloud();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Data synced to cloud storage!'),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sync failed: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSyncing = false;
                                    });
                                  }
                                }
                              },
                              icon: _isSyncing 
                                  ? SizedBox(
                                      width: 16, 
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                                      ),
                                    )
                                  : Icon(Icons.cloud_upload, size: 16, color: cs.primary),
                              label: Text(
                                _isSyncing ? 'Syncing...' : 'Sync',
                                style: TextStyle(color: cs.primary),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _showEditPersonalInfoDialog();
                              },
                              icon: Icon(Icons.edit, size: 16, color: cs.primary),
                              label: Text(
                                'Edit',
                                style: TextStyle(color: cs.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPersonalDetailRow(
                      context,
                      'Weight',
                      _weightController.text.isEmpty 
                          ? 'Not set' 
                          : '${_weightController.text} kg',
                      Icons.monitor_weight_outlined,
                    ),
                    _buildPersonalDetailRow(
                      context,
                      'Height',
                      _heightController.text.isEmpty 
                          ? 'Not set' 
                          : '${_heightController.text} cm',
                      Icons.height,
                    ),
                    _buildPersonalDetailRow(
                      context,
                      'Age',
                      _ageController.text.isEmpty 
                          ? 'Not set' 
                          : '${_ageController.text} years',
                      Icons.cake_outlined,
                    ),
                    _buildPersonalDetailRow(
                      context,
                      'Gender',
                      _selectedSex,
                      Icons.person_outline,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Enhanced Notification Settings
            _buildEnhancedNotificationSection(),

            const SizedBox(height: 12),

            // Quick Setting Tiles with better styling
            _buildEnhancedQuickSettingTile(
              icon: Icons.notifications_active,
              label: 'Notification Settings',
              description: 'Manage your alerts and reminders',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => const NotificationSettingsScreen(),
                ),
              ),
            ),
            _buildEnhancedQuickSettingTile(
              icon: Icons.lock_outline,
              label: 'Privacy & Security',
              description: 'Control your data and privacy',
              onTap: () => context.go('/profile/settings/privacy'),
            ),
            _buildEnhancedQuickSettingTile(
              icon: Icons.person_outline,
              label: 'Complete Profile Setup',
              description: 'Update your personal information and preferences',
              onTap: () => context.go('/personal-info-setup'),
            ),
            _buildEnhancedQuickSettingTile(
              icon: Icons.settings_outlined,
              label: 'App Preferences',
              description: 'Customize your app experience',
              onTap: () => context.go('/profile/settings/app'),
            ),
            _buildEnhancedQuickSettingTile(
              icon: Icons.logout,
              label: 'Sign Out',
              description: 'Logout from your account',
              isDestructive: true,
              onTap: () async {
                final bool? shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out of your account?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: cs.onSurface),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.error,
                          foregroundColor: cs.onError,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  try {
                    await ref.read(authRepositoryProvider).logout();
                    ref.invalidate(authStateProvider);
                    ref.invalidate(currentUserProvider);
                    print('DEBUG: Logout successful, providers invalidated');
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to logout: $e'),
                          backgroundColor: cs.error,
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

  // Helper methods for real data
  String _calculateCarbonSaved() {
    // Calculate based on saved workouts, sustainable choices, etc.
    // This could connect to your actual data service
    final double savedWorkouts = (_weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : 70) ?? 70;
    final int workoutDays = 30; // This should come from your workout data
    final double carbonPerWorkout = 0.5; // kg CO2 saved per workout
    return (savedWorkouts * carbonPerWorkout * workoutDays / 100).toStringAsFixed(1);
  }

  String _getCurrentStreak() {
    // Get actual streak from your data service
    // For now, calculate based on stored preferences
    return '7'; // This should come from your actual streak data
  }

  String _getWorkoutCount() {
    // Get actual workout count from your fitness data
    return '45'; // This should come from your workout history
  }

  String _getAchievementCount() {
    // Get actual achievement count
    final bool hasBasicInfo = _weightController.text.isNotEmpty && 
                             _heightController.text.isNotEmpty && 
                             _ageController.text.isNotEmpty;
    int count = 0;
    if (hasBasicInfo) count += 2; // Profile completion achievements
    if (_notificationsAllowed) count += 1; // Notification setup
    return count.toString();
  }

  Widget _buildPersonalDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...<Widget>[
          const SizedBox(height: 16),
          Divider(
            color: cs.outline.withOpacity(0.2),
            thickness: 1,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildEnhancedNotificationSection() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsAllowed ? cs.primary.withOpacity(0.3) : cs.outline.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_notificationsAllowed ? cs.primary : cs.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _notificationsAllowed
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _notificationsAllowed ? cs.primary : cs.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _notificationsAllowed 
                          ? 'Stay updated with personalized tips'
                          : 'Enable for personalized reminders',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_notificationsAllowed)
                FilledButton.tonal(
                  onPressed: () async {
                    final bool granted = await _notificationService.requestPermissions();
                    if (granted) {
                      setState(() => _notificationsAllowed = true);
                    }
                  },
                  child: const Text('Enable'),
                )
              else
                Icon(
                  Icons.check_circle,
                  color: cs.primary,
                  size: 24,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuickSettingTile({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color iconColor = isDestructive ? cs.error : cs.onSurfaceVariant;
    final Color labelColor = isDestructive ? cs.error : cs.onSurface;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: cs.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsAllowed ? cs.primary : cs.error,
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
                color: _notificationsAllowed ? cs.primary : cs.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Notification Settings',
                style: TextStyle(
                  color: cs.onSurface,
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
                color: cs.onSurfaceVariant,
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
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
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
                      backgroundColor: cs.primary,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary),
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: cs.primary,
        ),
      ],
    );
  }
}

class _EnhancedStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;
  
  const _EnhancedStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color cardColor = cs.surfaceContainerHigh;
    final Color borderColor = cs.outlineVariant;
    final Color textColor = cs.onSurface;
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
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bgColor = cs.surfaceContainerHigh;
    final Color textColor = cs.onSurface;
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
