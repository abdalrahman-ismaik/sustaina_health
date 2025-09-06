import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';
import '../providers/onboarding_progress_provider.dart';

class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Set the current step to 1 for welcome screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProgressProvider.notifier).setStep(1);
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
              ? <Color>[cs.surface, cs.surfaceContainerHighest]
              : <Color>[cs.primary.withOpacity(0.05), cs.secondary.withOpacity(0.05)],
            stops: const <double>[0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Progress bar
              const OnboardingProgressBar(currentStep: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 40),
                      // Hero illustration with Lottie animation
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              cs.primaryContainer.withOpacity(0.8),
                              cs.secondaryContainer.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: cs.shadow.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: <Widget>[
                            // Lottie background animation
                            Positioned.fill(
                              child: Lottie.asset(
                                'assets/lottie/particles_green.json',
                                fit: BoxFit.cover,
                                repeat: true,
                              ),
                            ),
                            // Main content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // Animated logo
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 1500),
                                    curve: Curves.elasticOut,
                                    builder: (BuildContext context, double value, Widget? child) {
                                      // Clamp value to ensure it's within valid range
                                      final double clampedValue = value.clamp(0.0, 1.0);
                                      return Transform.scale(
                                        scale: clampedValue,
                                        child: Opacity(
                                          opacity: clampedValue,
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: cs.surface.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: cs.shadow.withOpacity(0.2),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.eco,
                                              size: 64,
                                              color: cs.primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // App title with gradient text effect
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: cs.surface.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: cs.primary.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ShaderMask(
                                          shaderCallback: (Rect bounds) => LinearGradient(
                                            colors: <Color>[cs.primary, cs.secondary],
                                          ).createShader(bounds),
                                          child: Text(
                                            'Ghiraas',
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Your Wellness Journey Begins',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: cs.onSurface.withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
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
                      const SizedBox(height: 40),
                      
                      // Welcome title and subtitle
                      Text(
                        'Welcome to the Future of Health',
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
                          'Where your personal wellness meets environmental sustainability. Join millions on a journey that benefits both you and our planet.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Feature highlights with animations
                      _buildFeatureHighlights(context, cs),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Enhanced CTA button
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
                        onPressed: () => context.go('/onboarding/ai-features'),
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
                            Icon(Icons.rocket_launch, color: cs.onPrimary),
                            const SizedBox(width: 12),
                            Text(
                              'Get Started',
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
                      'Join 50,000+ users on their wellness journey',
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
  
  Widget _buildFeatureHighlights(BuildContext context, ColorScheme cs) {
    final List<Map<String, Object>> features = <Map<String, Object>>[
      <String, Object>{
        'icon': Icons.psychology,
        'title': 'AI-Powered',
        'subtitle': 'Smart recommendations',
        'color': cs.primary,
      },
      <String, Object>{
        'icon': Icons.eco,
        'title': 'Sustainable',
        'subtitle': 'Eco-friendly choices',
        'color': cs.secondary,
      },
      <String, Object>{
        'icon': Icons.trending_up,
        'title': 'Personalized',
        'subtitle': 'Tailored for you',
        'color': cs.tertiary,
      },
    ];

    return Row(
      children: features.map((Map<String, Object> feature) {
        final int index = features.indexOf(feature);
        return Expanded(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800 + (index * 200)),
            curve: Curves.elasticOut,
            builder: (BuildContext context, double value, Widget? child) {
              // Clamp value to ensure it's within valid range
              final double clampedValue = value.clamp(0.0, 1.0);
              return Transform.scale(
                scale: clampedValue,
                child: Opacity(
                  opacity: clampedValue,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (feature['color'] as Color).withOpacity(0.2)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: (feature['color'] as Color).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (feature['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: feature['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature['title'] as String,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['subtitle'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
} 