import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'SustainaHealth',
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: Color(0xFF111714),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              // fontFamily: 'Lexend',
                            ),
                          ),
                          SizedBox(width: 8),
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
                              widthFactor: 0.0, // Set to 0 for static, animate for real loading
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
              children: [
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