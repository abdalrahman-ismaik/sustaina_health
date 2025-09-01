import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
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
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [cs.primaryContainer, cs.primary.withOpacity(0.7)]
                    : [cs.primary, cs.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.security,
                    size: 40,
                    color: cs.onPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Data is Safe',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We prioritize your privacy with local data storage and transparent practices.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data Storage Section
            _buildPrivacySection(
              context,
              icon: Icons.storage,
              title: 'Local Data Storage',
              description: 'All your personal health data, workout records, meal plans, and preferences are stored locally on your device.',
              details: [
                'Data stays on your device',
                'No cloud synchronization',
                'Full control over your information',
                'Data persists across app sessions',
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Data Collection Section
            _buildPrivacySection(
              context,
              icon: Icons.visibility_off,
              title: 'No Data Collection',
              description: 'We do not collect, share, or transmit your personal health information to external servers.',
              details: [
                'No personal data sent to servers',
                'No third-party analytics',
                'No advertising tracking',
                'No social media integration',
              ],
            ),
            
            const SizedBox(height: 20),
            
            // User Control Section
            _buildPrivacySection(
              context,
              icon: Icons.admin_panel_settings,
              title: 'Your Control',
              description: 'You have complete control over your data and can manage it directly through the app.',
              details: [
                'Clear app data anytime',
                'Export your information',
                'Uninstall removes all data',
                'No account required',
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Security Features Section
            _buildPrivacySection(
              context,
              icon: Icons.lock,
              title: 'Security Features',
              description: 'Your data is protected with industry-standard security measures.',
              details: [
                'Encrypted local storage',
                'Secure authentication',
                'Regular security updates',
                'No unauthorized access',
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Footer Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: cs.outline.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: cs.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Privacy by Design',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app was built with privacy as a core principle. Your health data belongs to you and stays with you.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  
  Widget _buildPrivacySection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<String> details,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
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
                  children: [
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
          
          const SizedBox(height: 16),
          
          // Details List
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: cs.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    detail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
