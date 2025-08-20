import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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

    // Navigate to onboarding screen after 3 seconds
    // Use GoRouter for navigation
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Import go_router at the top if not already
        context.go('/onboarding/welcome');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Ghiraas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF111714),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.0,
                      // fontFamily: 'Lexend', // Uncomment if font is added
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your AI-Powered Sustainable Health Journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF648772),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      // fontFamily: 'Lexend',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            'Loading...',
                            style: TextStyle(
                              color: Color(0xFF111714),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              // fontFamily: 'Lexend',
                            ),
                          ),
                          Text(
                            '${(_loadingProgress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFF111714),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 8,
                          color: const Color(0xFFDCE5DF),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _loadingProgress,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111714),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF648772),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      // fontFamily: 'Lexend',
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
