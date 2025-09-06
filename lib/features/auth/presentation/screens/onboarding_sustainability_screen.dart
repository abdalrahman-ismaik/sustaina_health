import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';
import '../providers/onboarding_progress_provider.dart';
import '../../data/services/onboarding_service.dart';

class OnboardingSustainabilityScreen extends ConsumerWidget {
  const OnboardingSustainabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Set the current step to 3 for sustainability screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProgressProvider.notifier).setStep(3);
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
              ? <Color>[cs.surface, cs.surfaceContainerHighest]
              : <Color>[cs.primary.withOpacity(0.05), cs.secondary.withOpacity(0.08)],
            stops: const <double>[0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Progress bar
              const OnboardingProgressBar(currentStep: 3),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      // Earth/Sustainability Hero section
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              cs.primaryContainer.withOpacity(0.8),
                              cs.secondaryContainer.withOpacity(0.6),
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
                            // Animated background elements
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment.center,
                                      colors: <Color>[
                                        cs.primary.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                      stops: const <double>[0.0, 1.0],
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
                                  // Rotating Earth animation
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 2 * 3.14159),
                                    duration: const Duration(seconds: 8),
                                    builder: (BuildContext context, double angle, Widget? child) {
                                      return Transform.rotate(
                                        angle: angle / 8,
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: <Color>[cs.primary, cs.secondary],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(50),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: cs.primary.withOpacity(0.4),
                                                blurRadius: 20,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.public,
                                            size: 50,
                                            color: cs.onPrimary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // Sustainability badges
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      _buildSustainabilityBadge(context, cs, '🌱', 'Eco-Friendly'),
                                      const SizedBox(width: 12),
                                      _buildSustainabilityBadge(context, cs, '🌍', 'Planet Care'),
                                      const SizedBox(width: 12),
                                      _buildSustainabilityBadge(context, cs, '♻️', 'Zero Waste'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Impact stats
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: cs.surface.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: cs.primary.withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      'Join 50,000+ eco-conscious users',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: cs.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                        'Make a Positive Impact',
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
                          'Track your carbon footprint while improving your health. Every healthy choice you make contributes to a healthier planet.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Sustainability features
                      _buildSustainabilityFeature(
                        context,
                        cs,
                        Icons.eco,
                        'Carbon Footprint Tracking',
                        'Monitor and reduce your environmental impact with every healthy choice you make.',
                        cs.primary,
                        0,
                      ),
                      const SizedBox(height: 16),
                      _buildSustainabilityFeature(
                        context,
                        cs,
                        Icons.local_florist,
                        'Sustainable Nutrition',
                        'Discover plant-based recipes and local food options that benefit both you and the planet.',
                        cs.secondary,
                        200,
                      ),
                      const SizedBox(height: 16),
                      _buildSustainabilityFeature(
                        context,
                        cs,
                        Icons.directions_bike,
                        'Green Exercise Options',
                        'Outdoor workouts, cycling, and eco-friendly fitness routines that connect you with nature.',
                        cs.tertiary,
                        400,
                      ),
                      const SizedBox(height: 32),
                      
                      // Impact preview
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              cs.primaryContainer.withOpacity(0.3),
                              cs.secondaryContainer.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.trending_up,
                              size: 40,
                              color: cs.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your Potential Impact',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _buildImpactStat(context, cs, '2.5kg', 'CO₂ Saved\nper month'),
                                _buildImpactStat(context, cs, '150L', 'Water Saved\nper week'),
                                _buildImpactStat(context, cs, '30%', 'Waste\nReduction'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Enhanced start button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[cs.primary, cs.secondary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: cs.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Mark onboarding as completed
                          await OnboardingService.markOnboardingCompleted();
                          // Navigate to login
                          context.go('/login');
                        },
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
                            Icon(Icons.eco, color: cs.onPrimary),
                            const SizedBox(width: 12),
                            Text(
                              'Start Your Journey',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Begin your sustainable wellness journey today',
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
  
  Widget _buildSustainabilityBadge(BuildContext context, ColorScheme cs, String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSustainabilityFeature(
    BuildContext context,
    ColorScheme cs,
    IconData icon,
    String title,
    String description,
    Color accentColor,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ECO',
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
  
  Widget _buildImpactStat(BuildContext context, ColorScheme cs, String value, String label) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 