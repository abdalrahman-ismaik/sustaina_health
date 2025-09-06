import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';

class AppPreferencesScreen extends ConsumerWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ThemeMode themeMode = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? <Color>[cs.primaryContainer, cs.primary.withOpacity(0.7)]
                    : <Color>[cs.primary, cs.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.tune,
                    size: 40,
                    color: cs.onPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Customize Your Experience',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personalize the app to match your preferences and style.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Theme Section
            _buildPreferenceSection(
              context,
              icon: Icons.palette,
              title: 'Appearance',
              description: 'Choose how the app looks',
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 16),
                  _buildThemeOption(
                    context,
                    themeNotifier,
                    themeMode,
                    AppThemeMode.system,
                    'System Default',
                    'Follow your device settings',
                    Icons.phone_android,
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    themeNotifier,
                    themeMode,
                    AppThemeMode.light,
                    'Light Mode',
                    'Clean and bright interface',
                    Icons.light_mode,
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    themeNotifier,
                    themeMode,
                    AppThemeMode.dark,
                    'Dark Mode',
                    'Easy on the eyes in low light',
                    Icons.dark_mode,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Notifications Section
            _buildPreferenceSection(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              description: 'Manage your notification preferences',
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    context,
                    'Workout Reminders',
                    'Get reminded about your scheduled workouts',
                    Icons.fitness_center,
                    true, // Default enabled
                    (bool value) {
                      // TODO: Implement notification preferences
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    context,
                    'Meal Logging',
                    'Reminders to log your meals',
                    Icons.restaurant,
                    true,
                    (bool value) {
                      // TODO: Implement notification preferences
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    context,
                    'Sleep Tracking',
                    'Bedtime and wake-up reminders',
                    Icons.bedtime,
                    false,
                    (bool value) {
                      // TODO: Implement notification preferences
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Data Section
            _buildPreferenceSection(
              context,
              icon: Icons.storage,
              title: 'Data Management',
              description: 'Control your app data',
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 16),
                  _buildActionTile(
                    context,
                    'Export Data',
                    'Save your health data to device storage',
                    Icons.download,
                    () {
                      // TODO: Implement data export
                      _showFeatureComingSoon(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    'Clear Cache',
                    'Free up storage space',
                    Icons.cleaning_services,
                    () {
                      _showClearCacheDialog(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    'Reset App',
                    'Clear all data and start fresh',
                    Icons.restore,
                    () {
                      _showResetAppDialog(context);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Info Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: cs.outline.withOpacity(0.2)),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.eco,
                    color: cs.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sustaina Health',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your privacy-focused health companion',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreferenceSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
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
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  color: cs.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ThemeMode currentThemeMode,
    AppThemeMode optionThemeMode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isSelected = themeNotifier.currentAppThemeMode == optionThemeMode;
    
    return InkWell(
      onTap: () => themeNotifier.setTheme(optionThemeMode),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer.withOpacity(0.3) : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: cs.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
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
      ),
    );
  }
  
  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: cs.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isDestructive 
                  ? cs.errorContainer.withOpacity(0.3)
                  : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: isDestructive ? cs.error : cs.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDestructive ? cs.error : cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFeatureComingSoon(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: cs.surface,
        icon: Icon(Icons.info_outline, color: cs.primary, size: 32),
        title: Text(
          'Coming Soon',
          style: TextStyle(color: cs.onSurface),
        ),
        content: Text(
          'This feature will be available in a future update.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: cs.surface,
        icon: Icon(Icons.cleaning_services, color: cs.primary, size: 32),
        title: Text(
          'Clear Cache',
          style: TextStyle(color: cs.onSurface),
        ),
        content: Text(
          'This will clear temporary files and free up storage space. Your personal data will not be affected.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully'),
                  backgroundColor: cs.primary,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  void _showResetAppDialog(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: cs.surface,
        icon: Icon(Icons.warning, color: cs.error, size: 32),
        title: Text(
          'Reset App',
          style: TextStyle(color: cs.error),
        ),
        content: Text(
          'This will permanently delete all your data including workouts, meals, sleep records, and preferences. This action cannot be undone.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement app reset
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('App reset functionality coming soon'),
                  backgroundColor: cs.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
