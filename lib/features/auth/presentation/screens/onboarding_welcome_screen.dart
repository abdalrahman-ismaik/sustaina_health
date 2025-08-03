import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';
import '../providers/onboarding_progress_provider.dart';

class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set the current step to 1 for welcome screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProgressProvider.notifier).setStep(1);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                // Progress bar
                const OnboardingProgressBar(currentStep: 1),
                const SizedBox(height: 20),
                // Background image container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuC-8H4z9U0gV_T6hKIISOjVr9Ut7aPW3Thj6pJB_05hkzL0PTObCAwiQb_ZpcCYFEPKV4x-MvQmBVCbZostdzsXO5VsAtyedpuENVYFl6_cy2TOzAK12p6UzF4bcsI7eCx6RyLjc2ELmX9htACkOHgdAIftDXZgk1J8mm2krGkfgd-MXKFYc0osZpJhOyXYmYRHkpwpt-5eW_iLDBCmUknrzBAhcjghPEIfkS1NpO2nk6pJMQc5SMSrXIuOlcRCojjeaFD_bw6hzy41'
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Welcome to SustainaHealth',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF111714),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.0,
                      // fontFamily: 'Lexend',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Where your health meets sustainability',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF111714),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      // fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ],
            ),
            // Get Started button
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38E07B),
                        foregroundColor: const Color(0xFF111714),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                      onPressed: () {
                        context.go('/onboarding/ai-features');
                      },
                      child: const Text('Get Started', overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 