import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/data/services/hybrid_profile_service.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../presentation/providers/auth_providers.dart';

class ProfileSetupService {
  final HybridProfileService _profileService = HybridProfileService();

  /// Check if user has completed their basic profile setup
  /// Returns true if all required fields are filled
  Future<bool> hasCompletedProfileSetup() async {
    try {
      final UserProfile? profile = await _profileService.getUserProfile();
      
      if (profile == null) return false;
      
      // Check if essential profile fields are completed
      final bool hasBasicInfo = profile.weight != null &&
          profile.height != null &&
          profile.age != null &&
          profile.sex != null &&
          profile.sex!.isNotEmpty;
      
      final bool hasFitnessInfo = profile.fitnessGoal != null &&
          profile.fitnessGoal!.isNotEmpty &&
          profile.workoutsPerWeek != null &&
          profile.activityLevel != null &&
          profile.activityLevel!.isNotEmpty;
      
      return hasBasicInfo && hasFitnessInfo;
    } catch (e) {
      // If there's an error loading profile, assume not completed
      print('Error checking profile setup: $e');
      return false;
    }
  }

  /// Mark profile as completed (for future use)
  Future<void> markProfileSetupCompleted() async {
    // This could be used to store a flag in shared preferences
    // or in the user's cloud profile indicating setup is complete
    try {
      // For now, we rely on the profile data existence
      // In future, could add a "setupCompleted" flag to UserProfile model
      print('Profile setup marked as completed');
    } catch (e) {
      print('Error marking profile setup as completed: $e');
    }
  }

  /// Get the percentage of profile completion (0.0 to 1.0)
  Future<double> getProfileCompletionPercentage() async {
    try {
      final UserProfile? profile = await _profileService.getUserProfile();
      
      if (profile == null) return 0.0;
      
      int completedFields = 0;
      int totalRequiredFields = 7; // weight, height, age, sex, fitnessGoal, workoutsPerWeek, activityLevel
      
      if (profile.weight != null) completedFields++;
      if (profile.height != null) completedFields++;
      if (profile.age != null) completedFields++;
      if (profile.sex != null && profile.sex!.isNotEmpty) completedFields++;
      if (profile.fitnessGoal != null && profile.fitnessGoal!.isNotEmpty) completedFields++;
      if (profile.workoutsPerWeek != null) completedFields++;
      if (profile.activityLevel != null && profile.activityLevel!.isNotEmpty) completedFields++;
      
      return completedFields / totalRequiredFields;
    } catch (e) {
      print('Error calculating profile completion: $e');
      return 0.0;
    }
  }
}

// Provider for the ProfileSetupService
final profileSetupServiceProvider = Provider<ProfileSetupService>((ref) {
  return ProfileSetupService();
});

// Provider to check if profile setup is completed
final profileSetupCompletedProvider = FutureProvider<bool>((ref) async {
  // Watch the auth state to refresh when user changes
  final authState = ref.watch(authStateProvider);
  
  // Only check profile if user is authenticated
  if (!authState.hasValue || authState.value == null) {
    return false;
  }
  
  final service = ref.read(profileSetupServiceProvider);
  return await service.hasCompletedProfileSetup();
});

// Provider for profile completion percentage
final profileCompletionPercentageProvider = FutureProvider<double>((ref) async {
  final service = ref.read(profileSetupServiceProvider);
  return await service.getProfileCompletionPercentage();
});
