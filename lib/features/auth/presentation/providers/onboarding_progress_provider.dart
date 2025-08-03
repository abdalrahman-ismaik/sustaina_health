import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingProgressNotifier extends StateNotifier<int> {
  OnboardingProgressNotifier() : super(1);

  void setStep(int step) {
    state = step;
  }

  void nextStep() {
    if (state < 4) {
      state = state + 1;
    }
  }

  void previousStep() {
    if (state > 1) {
      state = state - 1;
    }
  }

  void reset() {
    state = 1;
  }
}

final StateNotifierProvider<OnboardingProgressNotifier, int> onboardingProgressProvider = StateNotifierProvider<OnboardingProgressNotifier, int>((StateNotifierProviderRef<OnboardingProgressNotifier, int> ref) {
  return OnboardingProgressNotifier();
}); 