import 'package:flutter/material.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/onboarding_service.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _loadingAnimation;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Create loading animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen to animation updates
    _loadingAnimation.addListener(() {
      setState(() {
        _loadingProgress = _loadingAnimation.value;
      });
    });

    // Start the animation
    _animationController.forward();

    // Let the router handle navigation based on auth state
    Timer(const Duration(seconds: 3), () async {
      if (mounted) {
        // Check authentication status first
        final AsyncValue<UserEntity?> authState = ref.read(authStateProvider);
        final bool isLoggedIn = authState.hasValue && authState.value != null;
        
        if (isLoggedIn) {
          // User is authenticated - go to home (router will handle profile setup check)
          context.go('/home');
        } else {
          // User is not authenticated - always show onboarding for fresh start
          // This ensures new users or users who haven't completed signup see onboarding
          final bool hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
          
          if (!hasSeenOnboarding) {
            // First time user - show onboarding
            context.go('/onboarding/welcome');
          } else {
            // Reset onboarding for non-authenticated users to ensure they see it again
            // This handles the case where user saw onboarding but didn't complete signup
            await OnboardingService.resetOnboarding();
            context.go('/onboarding/welcome');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? <Color>[cs.surface, cs.surfaceContainerHighest]
              : <Color>[cs.primary.withOpacity(0.1), cs.secondary.withOpacity(0.1)],
            stops: const <double>[0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Spacer(flex: 2),
              // Logo and branding section
              Column(
                children: <Widget>[
                  // Animated logo container
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.scale(
                        scale: 0.8 + (_loadingAnimation.value * 0.2),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[cs.primary, cs.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: cs.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.eco,
                            size: 60,
                            color: cs.onPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // App name with fade animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (BuildContext context, Widget? child) {
                      return Opacity(
                        opacity: _loadingAnimation.value,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Ghiraas',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cs.primary.withOpacity(0.3)),
                              ),
                              child: Text(
                                'AI-Powered Sustainable Wellness',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Enhanced loading section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Initializing...',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(_loadingProgress * 100).toInt()}%',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Enhanced progress bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: _loadingProgress,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cs.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Loading status text
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget? child) {
                            final List<String> loadingSteps = <String>[
                              'Loading resources...',
                              'Preparing AI models...',
                              'Setting up environment...',
                            ];
                            int currentStep = (_loadingProgress * loadingSteps.length).floor();
                            if (currentStep >= loadingSteps.length) currentStep = loadingSteps.length - 1;
                            
                            return Text(
                              loadingSteps[currentStep],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              // Bottom section
              Column(
                children: <Widget>[
                  // Feature highlights
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildFeatureIcon(context, Icons.fitness_center, 'Exercise'),
                        _buildFeatureIcon(context, Icons.restaurant_menu, 'Nutrition'),
                        _buildFeatureIcon(context, Icons.bedtime, 'Sleep'),
                        _buildFeatureIcon(context, Icons.eco, 'Eco-Friendly'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _loadingProgress * 0.6 + 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withOpacity(0.3)),
                ),
                child: Icon(
                  icon,
                  color: cs.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
