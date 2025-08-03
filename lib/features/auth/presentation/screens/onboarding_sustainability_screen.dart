import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';
import '../providers/onboarding_progress_provider.dart';

class OnboardingSustainabilityScreen extends ConsumerWidget {
  const OnboardingSustainabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set the current step to 3 for sustainability screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProgressProvider.notifier).setStep(3);
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
                const OnboardingProgressBar(currentStep: 3),
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
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuChdbUBtoWht0SkIfyxA3nO66ZnBXmQSZdLpLV1AA2NN9Dpusi0ijUPQXf2BYyuYse3lbZhwPHdZGW0yxkcQiTmo_7qtKMG7xnBOsKZGQP9iWsmOFYukmNdhyfv4AfS7xh2F6NnLwnbmy_34ZwwlukKIelFBSxWT0ASTuqH5rGQ2aW2N4loBRY85j33REUTa7L781aP6U5ELSg89dAI7IhA1v8F03P_NlXoMbJrimbdUfHtIgzXFhK2oQgPNKKPeMvW-s9hko3KFGqR'
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
                    'Make a Positive Impact',
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
                    'Track your eco-footprint while staying healthy',
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
            // Start Your Journey button
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
                        context.go('/login');
                      },
                      child: const Text('Start Your Journey', overflow: TextOverflow.ellipsis),
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