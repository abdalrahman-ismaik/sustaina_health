import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';
import '../providers/onboarding_progress_provider.dart';

class OnboardingAIScreen extends ConsumerWidget {
  const OnboardingAIScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Set the current step to 2 for AI features screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProgressProvider.notifier).setStep(2);
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
              ? <Color>[cs.surface, cs.surfaceContainerHighest]
              : <Color>[cs.secondary.withOpacity(0.05), cs.primary.withOpacity(0.05)],
            stops: const <double>[0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Progress bar
              const OnboardingProgressBar(currentStep: 2),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      // AI Hero section with GIF
                      Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              cs.secondaryContainer.withOpacity(0.8),
                              cs.tertiaryContainer.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: cs.shadow.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: <Widget>[
                            // Background decoration
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        cs.secondary.withOpacity(0.1),
                                        cs.primary.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Main content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // Animated AI icon with pulsing effect
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(seconds: 2),
                                    curve: Curves.easeInOut,
                                    builder: (BuildContext context, double value, Widget? child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: cs.surface.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: cs.secondary.withOpacity(0.3),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.psychology,
                                            size: 56,
                                            color: cs.secondary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // AI Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: cs.surface.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: cs.secondary.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          '🤖',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'AI-Powered Coach',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: cs.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Title and description
                      Text(
                        'Your Personal AI Coach',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outline.withOpacity(0.1)),
                        ),
                        child: Text(
                          'Experience intelligent recommendations powered by advanced AI. Get personalized insights for exercise, nutrition, and sleep that adapt to your unique lifestyle.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Enhanced feature cards
                      _buildEnhancedFeatureCard(
                        context,
                        cs,
                        Icons.fitness_center,
                        'Smart Exercise Plans',
                        'AI creates personalized workouts based on your fitness level, goals, and available equipment.',
                        cs.primary,
                        'assets/gif/home/running.gif',
                        0,
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedFeatureCard(
                        context,
                        cs,
                        Icons.restaurant_menu,
                        'Intelligent Nutrition',
                        'Get tailored meal plans and recipes that match your dietary preferences and health goals.',
                        cs.secondary,
                        'assets/gif/home/heart.gif',
                        200,
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedFeatureCard(
                        context,
                        cs,
                        Icons.bedtime,
                        'Sleep Tracking',
                        'Track your sleep patterns and get insights for better rest and recovery.',
                        cs.tertiary,
                        'assets/gif/home/greeting.gif',
                        400,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Enhanced next button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[cs.secondary, cs.tertiary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: cs.secondary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => context.go('/onboarding/sustainability'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.auto_awesome, color: cs.onSecondary),
                            const SizedBox(width: 12),
                            Text(
                              'Continue',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: cs.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Powered by advanced machine learning',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEnhancedFeatureCard(
    BuildContext context,
    ColorScheme cs,
    IconData icon,
    String title,
    String description,
    Color accentColor,
    String? gifPath,
    int animationDelay,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + animationDelay),
      curve: Curves.elasticOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value.clamp(0.0, 1.0))),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.2)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accentColor.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Icon container with gradient
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[accentColor.withOpacity(0.2), accentColor.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            // AI badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'AI',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Feature highlights
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Personalized',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Smart',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 