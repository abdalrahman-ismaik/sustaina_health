import 'package:flutter/material.dart';

class OnboardingAIScreen extends StatelessWidget {
  const OnboardingAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 0),
                    // Background image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuA6_UrNHyvAKq7zd301RSq6RgTWGZEX5Hm5s3l1LpNbFy-GicR-29km-WFGoKVXAsfg2sokIS_6xWy5zyQ4w0hDcHKJrTpNgTglHxSXNIcLJ2fgyeCwMpHJ466D9wlC4RoOpBGOsGfPgR5DSTqi9MTNnJzmpwH92yl71l8yOK0Vr8MVKWKRLzWIOnSknHml_bD6RsfoJ8p91R4mT4EHiPpcOWt8Q7p2_IcXQC0N7rlsgeyS0Xi2Db7IGs6kFU_uXYrjaWFrK4k-f2Hq'
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'AI-Powered Personal Coach',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111714),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          // fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Smart recommendations for exercise, nutrition, and sleep',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111714),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          // fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Feature cards
                    _FeatureCard(
                      icon: Icons.fitness_center,
                      title: 'Exercise',
                      description: 'Personalized workout plans based on your fitness level and goals',
                    ),
                    _FeatureCard(
                      icon: Icons.restaurant,
                      title: 'Nutrition',
                      description: 'Tailored meal plans and recipes to support your dietary needs',
                    ),
                    _FeatureCard(
                      icon: Icons.nightlight_round,
                      title: 'Sleep',
                      description: 'Optimize your sleep schedule for better rest and recovery',
                    ),
                  ],
                ),
              ),
            ),
            // Get Started button
            Column(
              children: [
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
                      onPressed: () {},
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF111714), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111714),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    // fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF648772),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    // fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 