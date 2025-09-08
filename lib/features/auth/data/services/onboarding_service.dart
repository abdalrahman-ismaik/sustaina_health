import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _hasCompletedSetupKey = 'has_completed_setup';
  
  /// Check if user has seen onboarding screens (but may not have signed up)
  static Future<bool> hasSeenOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }
  
  /// Check if user has completed full app setup (onboarding + authentication)
  static Future<bool> hasCompletedSetup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedSetupKey) ?? false;
  }
  
  /// Mark onboarding as seen (when user goes through onboarding screens)
  static Future<void> markOnboardingCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }
  
  /// Mark full setup as completed (when user signs up successfully)
  static Future<void> markSetupCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
    await prefs.setBool(_hasCompletedSetupKey, true);
  }
  
  /// Reset onboarding flags (for testing purposes)
  static Future<void> resetOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenOnboardingKey);
    await prefs.remove(_hasCompletedSetupKey);
  }
  
  /// Reset only the setup completion (for logout)
  static Future<void> resetSetupCompletion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasCompletedSetupKey);
  }
}
