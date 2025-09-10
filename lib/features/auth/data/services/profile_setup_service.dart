import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
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

      print('ProfileSetupService: Checking profile completion...');
      print('ProfileSetupService: Profile data: $profile');

      if (profile == null) {
        print('ProfileSetupService: No profile found');
        return false;
      }

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

      print('ProfileSetupService: hasBasicInfo: $hasBasicInfo');
      print('ProfileSetupService: hasFitnessInfo: $hasFitnessInfo');
      print(
          'ProfileSetupService: Profile completion: ${hasBasicInfo && hasFitnessInfo}');

      return hasBasicInfo && hasFitnessInfo;
    } catch (e) {
      // If there's an error loading profile, assume not completed
      print('Error checking profile setup: $e');
      return false;
    }
  }

  /// Check if user has any existing profile data at all
  /// This helps determine if we should skip asking for re-entry
  Future<bool> hasExistingProfileData() async {
    try {
      final UserProfile? profile = await _profileService.getUserProfile();

      print('ProfileSetupService: Checking existing data...');
      print('ProfileSetupService: Profile data: $profile');

      if (profile == null) {
        print('ProfileSetupService: No existing data found');
        return false;
      }

      // Check if any profile fields exist
      final bool hasData = profile.weight != null ||
          profile.height != null ||
          profile.age != null ||
          (profile.sex != null && profile.sex!.isNotEmpty) ||
          (profile.fitnessGoal != null && profile.fitnessGoal!.isNotEmpty) ||
          profile.workoutsPerWeek != null ||
          (profile.activityLevel != null &&
              profile.activityLevel!.isNotEmpty) ||
          profile.availableEquipment.isNotEmpty;

      print('ProfileSetupService: Has existing data: $hasData');
      return hasData;
    } catch (e) {
      print('Error checking existing profile data: $e');
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

  /// Debug method to check Firebase directly
  Future<void> debugCheckFirebaseData() async {
    try {
      print('=== DEBUG: Checking Firebase directly ===');

      // Force refresh by calling the service directly
      final UserProfile? profile = await _profileService.getUserProfile();
      print('Raw profile from HybridProfileService: $profile');

      if (profile != null) {
        print('Weight: ${profile.weight}');
        print('Height: ${profile.height}');
        print('Age: ${profile.age}');
        print('Sex: ${profile.sex}');
        print('Fitness Goal: ${profile.fitnessGoal}');
        print('Workouts Per Week: ${profile.workoutsPerWeek}');
        print('Activity Level: ${profile.activityLevel}');
        print('Equipment: ${profile.availableEquipment}');
      }

      final bool completed = await hasCompletedProfileSetup();
      final bool hasData = await hasExistingProfileData();

      print('Has completed setup: $completed');
      print('Has existing data: $hasData');
      print('=== END DEBUG ===');
    } catch (e) {
      print('Debug error: $e');
    }
  }

  /// Get the percentage of profile completion (0.0 to 1.0)
  Future<double> getProfileCompletionPercentage() async {
    try {
      final UserProfile? profile = await _profileService.getUserProfile();

      if (profile == null) return 0.0;

      int completedFields = 0;
      final int totalRequiredFields =
          7; // weight, height, age, sex, fitnessGoal, workoutsPerWeek, activityLevel

      if (profile.weight != null) completedFields++;
      if (profile.height != null) completedFields++;
      if (profile.age != null) completedFields++;
      if (profile.sex != null && profile.sex!.isNotEmpty) completedFields++;
      if (profile.fitnessGoal != null && profile.fitnessGoal!.isNotEmpty)
        completedFields++;
      if (profile.workoutsPerWeek != null) completedFields++;
      if (profile.activityLevel != null && profile.activityLevel!.isNotEmpty)
        completedFields++;

      return completedFields / totalRequiredFields;
    } catch (e) {
      print('Error calculating profile completion: $e');
      return 0.0;
    }
  }
}

// Provider for the ProfileSetupService
final Provider<ProfileSetupService> profileSetupServiceProvider =
    Provider<ProfileSetupService>((ProviderRef<ProfileSetupService> ref) {
  return ProfileSetupService();
});

// Provider to check if profile setup is completed
final AutoDisposeFutureProvider<bool> profileSetupCompletedProvider =
    FutureProvider.autoDispose<bool>(
        (AutoDisposeFutureProviderRef<bool> ref) async {
  // Watch the auth state to refresh when user changes
  final AsyncValue<UserEntity?> authState = ref.watch(authStateProvider);

  // Only check profile if user is authenticated
  if (!authState.hasValue || authState.value == null) {
    return false;
  }

  final ProfileSetupService service = ref.read(profileSetupServiceProvider);
  return await service.hasCompletedProfileSetup();
});

// Provider to check if user has any existing profile data
final AutoDisposeFutureProvider<bool> hasExistingProfileDataProvider =
    FutureProvider.autoDispose<bool>(
        (AutoDisposeFutureProviderRef<bool> ref) async {
  // Watch the auth state to refresh when user changes
  final AsyncValue<UserEntity?> authState = ref.watch(authStateProvider);

  // Only check profile if user is authenticated
  if (!authState.hasValue || authState.value == null) {
    return false;
  }

  final ProfileSetupService service = ref.read(profileSetupServiceProvider);
  return await service.hasExistingProfileData();
});

// Provider for profile completion percentage
final FutureProvider<double> profileCompletionPercentageProvider =
    FutureProvider<double>((FutureProviderRef<double> ref) async {
  final ProfileSetupService service = ref.read(profileSetupServiceProvider);
  return await service.getProfileCompletionPercentage();
});

// Debug provider to force check Firebase
final FutureProvider<void> debugProfileProvider =
    FutureProvider<void>((FutureProviderRef<void> ref) async {
  final ProfileSetupService service = ref.read(profileSetupServiceProvider);
  await service.debugCheckFirebaseData();
});
