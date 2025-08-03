import 'package:flutter/material.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: List.generate(totalSteps, (int index) {
          final bool isFilled = index < currentStep;
          final bool isLast = index == totalSteps - 1;
          
          return Expanded(
            child: Row(
              children: <Widget>[
                // Individual progress bar segment
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isFilled 
                        ? const Color(0xFF38E07B)
                        : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Spacing between bars (except for the last one)
                if (!isLast)
                  const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
} 